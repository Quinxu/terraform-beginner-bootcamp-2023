output "bucket_name" {
  value = aws_s3_bucket.terraform_bucket.bucket
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_configuration.website_endpoint
}

# locals {
#   l_error_file_path = var.error_html_file_path
#   l_index_file_path = var.index_html_file_path
# }

# output "error_file_path_value" {
#   value = local.l_error_file_path
# }

# output "index_file_path_value" {
#   value = local.l_index_file_path
# }