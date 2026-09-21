output "acr_id" {
  description = "The ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "The login server URL of the container registry"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "The admin username if admin_enabled is true"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "The admin password if admin_enabled is true"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
