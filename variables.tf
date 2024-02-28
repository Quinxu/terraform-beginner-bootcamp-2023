
variable "terratowns_endpoint" {
  type    = string
}

variable "terratowns_access_token" {
  type    = string
}

variable "teacherseat_user_uuid" {
  type    = string
}

# variable "bucket_name" {
# #   description = "The name of the S3 bucket"
#   type        = string
# }

# variable "index_html_file_path" {
#   type        = string
# }

# variable "error_html_file_path" {
#   type        = string
# }

variable "carving" {
  type =  object({
    public_path = string
    content_version = number
  })
}

# variable "carving_content_version" {
#   type        = number
# }

# variable "assets_path" {
#   type        = string
# }

# variable "carving_public_path" {
#   description = "Path to the public folder"
#   type        = string
# }