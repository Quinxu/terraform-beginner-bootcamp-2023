
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
     aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
  cloud {
    organization = "qinxu"

    workspaces {
      name = "terra-house-1"
    }
  }
}

provider "random" {
  # Configuration options
}

#https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "bucket_name" {
  length = 32
  special = false
  lower = true
  upper = false
}


output "random_bucket_name" {
  value = random_string.bucket_name.result
}

provider "aws" {
  # Configuration options
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "example" {
  #Bucket Naming Rules
  #https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
  bucket = random_string.bucket_name.result

  # tags = {
  #   Name        = "My bucket"
  #   Environment = "Dev"
  # }
}