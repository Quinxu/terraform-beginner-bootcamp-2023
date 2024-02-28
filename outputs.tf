output "bucket_name" {
    # value = module.terrahouse_aws.bucket_name
  
  value = module.home_carving_hosting.bucket_name
}

output "s3_website_endpoint" {
  description = "s3 static website hosting endpoint"
  value = module.home_carving_hosting.website_endpoint
}

output "domain_name" {
  description = "The cloudfront distribution domain name"
  value = module.home_carving_hosting.domain_name
}