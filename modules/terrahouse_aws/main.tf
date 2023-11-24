terraform {
  required_providers {
     aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

# provider "aws" {
#   # Configuration options
# }

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform_bucket" {
  #Bucket Naming Rules
  #https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
  bucket = var.bucket_name

  tags = {
    UserUuid = var.user_uuid
  }
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.terraform_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }  
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  key    = "index.html"
  source = var.index_html_file_path

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5(var.index_html_file_path)
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  key    = "error.html"
  source = var.error_html_file_path

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5(var.error_html_file_path)
}