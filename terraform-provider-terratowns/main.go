package main

import (
	"fmt"
	"log"
	"github.com/google/uuid"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/plugin"
)

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
		
		},
		DataSourcesMap: map[string]*schema.Resource{

		},
		schema: map[string]*schema.Schema{
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
				// ValidateFunc: validateUUID
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
	log.print("validateUUID:start")
	value := v.(string)

	_, err := uuid.Parse(value)
	if err != nil {
		errors = append(errors, fmt.Errorf("%s isn't a valid UUID: %s", k, err))
	}

	log.print("validateUUID:end")
	return
}

func providerConfigure(p *schema.Provider) schema.ConfigureContextFunc {
	return func(ctx context.Context, d *schema.ResourceData) (interface{}, diag.Diagnostics ) {
		log.Print("providerConfigure:start")
		config := Config{
			Endpoint: d.Get("endpoint").(string),
			Token: d.Get("token").(string),
			UserUuid: d.Get("user_uuid").(string),
		}
		log.Print("providerConfigure:end")
		return &config, nil
	}
}
