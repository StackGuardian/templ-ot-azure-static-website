variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "demo"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "Use 2-16 lowercase letters, digits or hyphens, starting with a letter."
  }
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "germanywestcentral"
}

# Grouped so the StackGuardian form can show them in one "Advanced Settings" section.
variable "advanced_settings" {
  description = "Settings most deployments keep at their defaults"
  type = object({
    log_retention_days = optional(number, 90)      # Retention of the storage access logs in Log Analytics
    tags               = optional(map(string), {}) # Additional tags for all resources
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.advanced_settings.log_retention_days >= 30 && var.advanced_settings.log_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}
