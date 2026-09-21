variable "acr_name" {
  description = "Name of the Azure Container Registry (alphanumeric only)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for ACR"
  type        = string
}

variable "sku" {
  description = "The SKU of the container registry (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Should the admin user be enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to ACR"
  type        = map(string)
  default     = {}
}
