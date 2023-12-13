                                

   variable "user_uuid" {
  type    = string
  description = "The UUID of the user"
  
  validation {
    # condition     = regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.user_uuid)
    condition        = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.user_uuid))
    error_message = "Invalid UUID format. Please provide a valid UUID."
  }
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string

  validation {
    condition     = (
      length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63 && 
      can(regex("^[a-z0-9][a-z0-9-.]*[a-z0-9]$", var.bucket_name))
    )
    error_message = "The bucket name must be between 3 and 63 characters, start and end with a lowercase letter or number, and can contain only lowercase letters, numbers, hyphens, and dots."
  }
}

locals {
  index_file_path = "${path.root}/public/${var.index_html_file_path}"
  error_file_path ="${path.root}/public/${var.error_html_file_path}"
}

variable "index_html_file_path" {
  type        = string
  description = "Path to the index.html file"

  # validation {
  #   condition     = fileexists(var.index_html_file_path)
  #   error_message = "The specified index.html file does not exist."
  # }
}

variable "error_html_file_path" {
  type        = string
  description = "Path to the error.html file"

  # validation {
  #   condition     = fileexists(var.error_html_file_path)
  #   error_message = "The specified error.html file does not exist."
  # }
}