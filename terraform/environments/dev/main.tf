locals {
  resource_group_name           = "rg-${var.project_name}-${var.environment}"
  resource_group_name_secondary = "rg-${var.project_name}-${var.environment}-si"
  vnet_name                     = "vnet-${var.project_name}-${var.environment}"
  vnet_name_secondary           = "vnet-${var.project_name}-${var.environment}-si"
  aks_subnet_name               = "snet-aks-${var.environment}"
  aks_subnet_name_secondary     = "snet-aks-${var.environment}-si"
  acr_name                      = replace("${var.project_name}${var.environment}acr", "-", "")
  aks_cluster_name              = "aks-${var.project_name}-${var.environment}"
  aks_cluster_name_secondary    = "aks-${var.project_name}-${var.environment}-si"
  aks_dns_prefix                = "${var.project_name}-${var.environment}"
  aks_dns_prefix_secondary      = "${var.project_name}-${var.environment}-si"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# Primary Region: Central India (Active)
# ==========================================
module "resource_group" {
  source = "../../modules/resource-group"

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = local.tags
}

module "network" {
  source = "../../modules/network"

  vnet_name                   = local.vnet_name
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  address_space               = var.vnet_address_space
  aks_subnet_name             = local.aks_subnet_name
  aks_subnet_address_prefixes = var.aks_subnet_address_prefixes
  tags                        = local.tags
}

module "acr" {
  source = "../../modules/acr"

  acr_name            = local.acr_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = local.tags
}

module "aks" {
  source = "../../modules/aks"

  cluster_name        = local.aks_cluster_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  dns_prefix          = local.aks_dns_prefix
  node_count          = var.node_count
  vm_size             = var.vm_size
  vnet_subnet_id      = module.network.aks_subnet_id
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = module.aks.kubelet_identity_object_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.acr_id
  skip_service_principal_aad_check = true
}

# ==========================================
# Secondary Region: South India (Standby / DR)
# ==========================================
module "resource_group_secondary" {
  source = "../../modules/resource-group"

  resource_group_name = local.resource_group_name_secondary
  location            = var.location_secondary
  tags                = local.tags
}

module "network_secondary" {
  source = "../../modules/network"

  vnet_name                   = local.vnet_name_secondary
  resource_group_name         = module.resource_group_secondary.resource_group_name
  location                    = module.resource_group_secondary.resource_group_location
  address_space               = var.vnet_address_space_secondary
  aks_subnet_name             = local.aks_subnet_name_secondary
  aks_subnet_address_prefixes = var.aks_subnet_address_prefixes_secondary
  tags                        = local.tags
}

module "aks_secondary" {
  source = "../../modules/aks"

  cluster_name        = local.aks_cluster_name_secondary
  resource_group_name = module.resource_group_secondary.resource_group_name
  location            = module.resource_group_secondary.resource_group_location
  dns_prefix          = local.aks_dns_prefix_secondary
  node_count          = var.node_count
  vm_size             = var.vm_size
  vnet_subnet_id      = module.network_secondary.aks_subnet_id
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_secondary_acr_pull" {
  principal_id                     = module.aks_secondary.kubelet_identity_object_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.acr_id
  skip_service_principal_aad_check = true
}

# ==========================================
# Global Routing & Failover: Azure Front Door
# ==========================================
resource "azurerm_cdn_frontdoor_profile" "afd" {
  name                = "afd-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = local.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "afd-${var.project_name}-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
}

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "og-orderhub"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
  session_affinity_enabled = false

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }

  health_probe {
    path                = "/health"
    protocol            = "Http"
    interval_in_seconds = 15
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "primary" {
  name                          = "origin-centralindia"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true

  certificate_name_check_enabled = false
  host_name                      = var.primary_ingress_ip
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.primary_ingress_ip
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_origin" "secondary" {
  name                          = "origin-southindia"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true

  certificate_name_check_enabled = false
  host_name                      = var.secondary_ingress_ip
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.secondary_ingress_ip
  priority                       = 2
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "route-orderhub"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [
    azurerm_cdn_frontdoor_origin.primary.id,
    azurerm_cdn_frontdoor_origin.secondary.id
  ]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpOnly"
  link_to_default_domain = true
  https_redirect_enabled = false
}



