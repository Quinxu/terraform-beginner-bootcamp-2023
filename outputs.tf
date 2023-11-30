output "bucket_name" {
    value = module.terrahouse_aws.bucket_name
  
}

output "s3_website_endpoint" {
  description = "s3 static website hosting endpoint"
  value = module.terrahouse_aws.website_endpoint
}

output "cloudfront_url" {
  description = "The cloudfront distribution domain name"
  value = module.terrahouse_aws.cloudfront_url
}