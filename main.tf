terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
    # random = {
    #   source = "hashicorp/random"
    #   version = "3.5.1"
    # }
    
  }

  cloud {
    organization = "qinxu"

    workspaces {
      name = "terra-house-1"
    }
  }
  
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

provider "terratowns" {
  # endpoint = "http://localhost:4567/api"
  endpoint = var.terratowns_endpoint
  # user_uuid = "e328f4ab-b99f-421c-84c9-4ccea042c7d1"
  user_uuid = var.teacherseat_user_uuid
  # token = "9b49b3fb-b8e9-483c-b703-97ba88eef8e0"
  token = var.terratowns_access_token

  
}

module "terrahouse_aws"{
  source = "./modules/terrahouse_aws"
  user_uuid = var.teacherseat_user_uuid
  # bucket_name = var.bucket_name
  index_html_file_path = var.index_html_file_path
  error_html_file_path = var.error_html_file_path
  content_version = var.content_version
  assets_path = var.assets_path
}

resource "terratowns_home" "home" {
  name = "How to carve a pumpkin in 2024!"
  description = <<DESCRIPTION
It shows the detailed steps to carve a pumpkin.
DESCRIPTION
  # description = "This is a town located in the west coast. \\nWith population about 10,000."
  domain_name = module.terrahouse_aws.cloudfront_url
  # domain_name = "3fdq3gzxq1.cloudfront.net"
  # town = "gamers-grotto"
  town = "missingo"
  content_version = 1
}

module "terrahouse_aws"{
  source = "./modules/terrahouse_aws"
  user_uuid = var.teacherseat_user_uuid
  # bucket_name = var.bucket_name
  index_html_file_path = var.index_html_file_path
  error_html_file_path = var.error_html_file_path
  content_version = var.content_version
  assets_path = var.assets_path
}

resource "terratowns_home" "home" {
  name = "How to roast a duck in 2024!"
  description = <<DESCRIPTION
It shows the detailed steps to roast a duck.
DESCRIPTION
  # description = "This is a town located in the west coast. \\nWith population about 10,000."
  domain_name = module.terrahouse_aws.cloudfront_url
  # domain_name = "3fdq3gzxq1.cloudfront.net"
  # town = "gamers-grotto"
  town = "missingo"
  content_version = 1
}
