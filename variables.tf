variable "user_uuid" {
  type    = string
  description = "The UUID of the user"
  
  validation {
    condition     = regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.user_uuid)
    error_message = "Invalid UUID format. Please provide a valid UUID."
  }
}