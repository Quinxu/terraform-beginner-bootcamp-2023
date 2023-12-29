package main

import (
	"fmt"
	"log"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/plugin"
	"github.com/google/uuid"
)

func main() {

	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: func() *schema.Provider {
			return &schema.Provider{
				ResourcesMap: map[string]*schema.Resource{
					"custom_resource": resourceCustom(),
				},
				
			}
		},
	})	
}

func resourceCustom() *schema.Resource {
	return &schema.Resource{
		// 
		
		DataSourcesMap: map[string]*schema.Resource{

		},
		schema: map[string]*schema.Resource{
			"endpoint":{
				Type: schema.TypeString,
				Required: true,
				Description: "The endpoint for the external service"
			},
			"token": {
				Type: schema.TypeString,
				Sensitive: true,
				Required: true,
				Description: "Bearer token for authorization"
			},
			"user_uuid":{
				Type: schema.TypeString,
				Required: true,
				Description: "UUID for configuration"
				ValidateFunc: validateUUID
			}
		}

		// Schema: map[string]*schema.Schema{
		// 	"user_uuid": {
		// 		Type:     schema.TypeString,
		// 		Required: true,
		// 	},
		// 	"uuid": {
		// 		Type:     schema.TypeString,
		// 		Computed: true,
		// 	},
		// 	// Add other fields as needed
		// },
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