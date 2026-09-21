output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.resource_group_name
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.network.vnet_name
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = module.acr.acr_name
}

output "acr_login_server" {
  description = "The login server of the container registry"
  value       = module.acr.login_server
}

output "aks_cluster_name" {
  description = "The name of the primary AKS cluster (Central India)"
  value       = module.aks.cluster_name
}

output "aks_cluster_name_secondary" {
  description = "The name of the secondary AKS cluster (South India)"
  value       = module.aks_secondary.cluster_name
}

output "resource_group_name_secondary" {
  description = "The name of the secondary resource group (South India)"
  value       = module.resource_group_secondary.resource_group_name
}

output "aks_kube_config_raw" {
  description = "Raw Kubernetes configuration to connect to the cluster"
  value       = module.aks.kube_config_raw
  sensitive   = true
}

output "frontdoor_endpoint_hostname" {
  description = "The global FQDN of the Azure Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
}


