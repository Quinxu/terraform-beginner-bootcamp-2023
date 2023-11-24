terraform {
  required_providers {
    # random = {
    #   source = "hashicorp/random"
    #   version = "3.5.1"
    # }
    
  }

  # cloud {
  #   organization = "qinxu"

  #   workspaces {
  #     name = "terra-house-1"
  #   }
  # }
  
}

# provider "random" {
#   # Configuration options
# }



#https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
# resource "random_string" "bucket_name" {
#   length = 32
#   special = false
#   lower = true
#   upper = false
# }

module "terrahouse_aws"{
  source = "./modules/terrahouse_aws"
  user_uuid = var.user_uuid
  bucket_name = var.bucket_name
  index_html_file_path = var.index_html_file_path
  error_html_file_path = var.error_html_file_path
}
