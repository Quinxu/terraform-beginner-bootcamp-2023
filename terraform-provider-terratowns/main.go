// main package is special in Go, it is where the execution of program starts.
package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt" //the package contains formatted I/O functions
	"log"
	"net/http"

	"github.com/google/uuid"

	//"github.com/hashicorp/go-uuid"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/plugin"
)

type Config struct {

	Endpoint string
	Token string
	UserUuid string
}

//defines the main function, the entry point of the application
func main() {

	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: provider, 
		// func() *schema.Provider {
		// 	return &schema.Provider{
		// 		ResourcesMap: map[string]*schema.Resource{
		// 			"custom_resource": resourceCustom(),
		// 		},
				
		// 	}
		// },
	})	
}
//func name with uppercase letter, is considered as exported (public) and can be accessed from other packages. 
//If it starts with a lowercase letter, it is considered unexported (private) and can only be accessed within the same package.
func provider() *schema.Provider{
	var p *schema.Provider
	p = &schema.Provider{
		ResourcesMap: map[string]*schema.Resource{
			"terratowns_home": Resource(),
		},
		DataSourcesMap: map[string]*schema.Resource{

		},
		Schema: map[string]*schema.Schema{
			"endpoint":{
				Type: schema.TypeString,
				Required: true,
				Description: "The endpoint for the external service",
			},
			"token": {
				Type: schema.TypeString,
				Sensitive: true,
				Required: true,
				Description: "Bearer token for authorization",
			},
			"user_uuid":{
				Type: schema.TypeString,
				Required: true,
				Description: "UUID for configuration",
				ValidateFunc: validateUUID,
			},
		},

	}
	p.ConfigureContextFunc = providerConfigure(p)
	return p
}

func resourceCustom() *schema.Resource {
	return &schema.Resource{
		// 
		Schema: map[string]*schema.Schema{
			"user_uuid": {
				Type:     schema.TypeString,
				Required: true,
			},
			"uuid": {
				Type:     schema.TypeString,
				Computed: true,
			},
			// Add other fields as needed
		},
	}
}

func validateUUID(v interface{}, k string) (ws []string, errors []error) {
	log.Print("validateUUID:start")
	value := v.(string)

	_, err := uuid.Parse(value)//ParseUUID(value)//.Parse(value)
	if err != nil {
		errors = append(errors, fmt.Errorf("%s isn't a valid UUID: %s", k, err))
	}

	log.Print("validateUUID:end")
	return
}

func providerConfigure(p *schema.Provider) schema.ConfigureContextFunc {
	return func(ctx context.Context, d *schema.ResourceData) (interface{}, diag.Diagnostics) {
		log.Print("providerConfigure:start")
		config :=  Config{
			Endpoint: d.Get("endpoint").(string),
			Token: d.Get("token").(string),
			UserUuid: d.Get("user_uuid").(string),
		}
		log.Print("providerConfigure:end")
		return &config, nil
	}
}

func Resource() *schema.Resource {
	log.Print("Resource:start")
	resource:= &schema.Resource{
		CreateContext: resourceHouseCreate,
		ReadContext: resourceHouseRead,
		UpdateContext: resourceHouseUpdate,
		DeleteContext: resourceHouseDelete,
		Schema: map[string]*schema.Schema{
			"name":{
				Type: schema.TypeString,
				Required: true,		
				Description: "Name of home",
			},
			"description": {
				Type: schema.TypeString,
				Required: true,
				Description: "Description of home",
			},
			"domain_name":{
				Type: schema.TypeString,
				Required: true,
				Description: "Domain Name of home eg. *.cloudfront.net",
			},
			"town": {
				Type: schema.TypeString,
				Required: true,
				Description: "The Name of home town",
			},
			"content_version":{
				Type: schema.TypeInt,
				Required: true,
				Description: "The content version of the home",
			},
		},
	}
	log.Print("Resource:end")
	return resource
}

func resourceHouseCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	log.Print("resourceHouseCreate:start")
	var diags diag.Diagnostics
	config := m.(*Config)

	payload := map[string]interface{}{
		"name": d.Get("name").(string),
		"description": d.Get("description").(string),
		"domain_name": d.Get("domain_name").(string),
		"town": d.Get("town").(string),
		"content_version": d.Get("content_version").(int),
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return diag.FromErr(err)
	}

	//construct the http request
	url :=  config.Endpoint+"/u/"+config.UserUuid+"/homes"
	log.Print("URL: "+ url)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return diag.FromErr(err)
	}
	//set headers
	req.Header.Set("Authorization","Bearer "+config.Token)
	req.Header.Set("Content-Type","application/json")
	req.Header.Set("Accept","application/json")

	//make http request
	client := http.Client{}
	resp, err := client.Do(req)
	
	if err != nil {
		return diag.FromErr(err)
	}
	defer resp.Body.Close()

	//parse response JSON
	var respData map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&respData); err != nil {
		return diag.FromErr(err)
	}

	//http resp code 200
	if resp.StatusCode != http.StatusOK {
		return diag.FromErr(fmt.Errorf("failed to create home resource, status_code:%d, status:%s, body: %s",resp.StatusCode, resp.Status,respData))
	}
	//handle resp status

	
	homeUUID := respData["uuid"].(string)
	d.SetId(homeUUID)

	log.Print("resourceHouseCreate:end")

	return diags
}

func resourceHouseRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	log.Print("resourceHouseRead:start")
	var diags diag.Diagnostics
	config := m.(*Config)
	homeUUID := d.Id()

	//construct the http request
	url := config.Endpoint+"/u/"+config.UserUuid+"/homes/"+homeUUID
	log.Print("URL: "+ url)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return diag.FromErr(err)
	}
	//set headers
	req.Header.Set("Authorization","Bearer "+config.Token)
	req.Header.Set("Content-Type","application/json")
	req.Header.Set("Accept","application/json")

	//make http request
	client := http.Client{}
	resp, err := client.Do(req)
	
	if err != nil {
		return diag.FromErr(err)
	}
	defer resp.Body.Close()

	var respData map[string]interface{}
	//http resp code 200
	if resp.StatusCode == http.StatusOK {
		//parse resp JSON
		
		if err := json.NewDecoder(resp.Body).Decode(&respData); err != nil {
			return diag.FromErr(err)
		}
		d.Set("name",respData["name"].(string))
		d.Set("description", respData["description"].(string))
		d.Set("domain_name", respData["domain_name"].(string))
		d.Set("town",respData["town"].(string))
		d.Set("content_version", respData["content_version"].(int))
		
	}else if resp.StatusCode == http.StatusNotFound {
		d.SetId("")
	}else if resp.StatusCode != http.StatusOK {
		return diag.FromErr(fmt.Errorf("failed to read home resource, status_code:%d, status:%s, body: %s",resp.StatusCode, resp.Status,respData))
	}

	log.Print("resourceHouseRead:end")
	return diags
}

func resourceHouseUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	log.Print("resourceHouseUpdate:start")
	var diags diag.Diagnostics
	config := m.(*Config)
	homeUUID := d.Id()

	payload := map[string]interface{}{
		"name": d.Get("name").(string),
		"description": d.Get("description").(string),
		"content_version": d.Get("content_version").(int),
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return diag.FromErr(err)
	}

	//construct the http request
	url := config.Endpoint+"/u/"+config.UserUuid+"/homes/"+homeUUID
	log.Print("URL: "+ url)
	req, err := http.NewRequest("PUT", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return diag.FromErr(err)
	}
	//set headers
	req.Header.Set("Authorization","Bearer "+config.Token)
	req.Header.Set("Content-Type","application/json")
	req.Header.Set("Accept","application/json")

	//make http request
	client := http.Client{}
	resp, err := client.Do(req)
	
	if err != nil {
		return diag.FromErr(err)
	}
	defer resp.Body.Close()

	//http resp code 200
	if resp.StatusCode != http.StatusOK {
		return diag.FromErr(fmt.Errorf("failed to update home resource, status_code:%d, status:%s",resp.StatusCode, resp.Status))
	}

	d.Set("name", payload["name"])
	d.Set("description", payload["description"])
	d.Set("content_version",payload["content_version"])

	log.Print("resourceHouseUpdate:end")
	return diags
}

func resourceHouseDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	log.Print("resourceHouseDelete:start")
	var diags diag.Diagnostics
	config := m.(*Config)
	homeUUID := d.Id()

	//construct the http request
	url :=  config.Endpoint+"/u/"+config.UserUuid+"/homes/"+homeUUID
	log.Print("URL: "+ url)
	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		return diag.FromErr(err)
	}

	//set headers
	req.Header.Set("Authorization","Bearer "+config.Token)
	req.Header.Set("Content-Type","application/json")
	req.Header.Set("Accept","application/json")

	//make http request
	client := http.Client{}
	resp, err := client.Do(req)
	
	if err != nil {
		return diag.FromErr(err)
	}
	defer resp.Body.Close()

	//http resp code 200
	if resp.StatusCode != http.StatusOK {
		return diag.FromErr(fmt.Errorf("failed to delete home resource, status_code:%d, status:%s",resp.StatusCode, resp.Status))
	}

	d.SetId("")
	log.Print("resourceHouseDelete:end")
	return diags
}