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
  user_uuid = var.teacherseat_user_uuid
  token = var.terratowns_access_token

  
}

module "home_carving_hosting"{
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path = var.carving.public_path
  content_version = var.carving.content_version
}

resource "terratowns_home" "home_carving" {
  name = "How to carve a pumpkin in 2024!"
  description = <<DESCRIPTION
It shows the detailed steps to carve a pumpkin.
DESCRIPTION
  # description = "This is a town located in the west coast. \\nWith population about 10,000."
  domain_name = module.home_carving_hosting.domain_name
  # domain_name = "3fdq3gzxq1.cloudfront.net"
  # town = "gamers-grotto"
  town = "missingo"
  content_version = var.carving.content_version
}

module "home_roasting_hosting"{
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path = var.roasting.public_path
  content_version = var.roasting.content_version
}

resource "terratowns_home" "home_roasting" {
  name = "How to roast a duck in 2024!"
  description = <<DESCRIPTION
It shows the detailed steps to roast a duck.
DESCRIPTION
  # description = "This is a town located in the west coast. \\nWith population about 10,000."
  domain_name = module.home_roasting_hosting.domain_name
  # domain_name = "3fdq3gzxq1.cloudfront.net"
  # town = "gamers-grotto"
  town = "missingo"
  content_version = var.roasting.content_version
}
