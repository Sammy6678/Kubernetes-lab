variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Primary Azure region for deployment"
  type        = string
  default     = "centralindia"
}

variable "location_secondary" {
  description = "Secondary Azure region for disaster recovery"
  type        = string
  default     = "southindia"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "orderhub"
}

variable "vnet_address_space" {
  description = "Address space for primary dev VNet"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "vnet_address_space_secondary" {
  description = "Address space for secondary dev VNet"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "aks_subnet_address_prefixes" {
  description = "Subnet address prefixes for primary AKS nodes"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "aks_subnet_address_prefixes_secondary" {
  description = "Subnet address prefixes for secondary AKS nodes"
  type        = list(string)
  default     = ["10.20.1.0/24"]
}

variable "node_count" {
  description = "Number of AKS worker nodes"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Virtual machine size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "primary_ingress_ip" {
  description = "Public IP of Primary Ingress Controller (Central India)"
  type        = string
  default     = "4.224.190.98"
}

variable "secondary_ingress_ip" {
  description = "Public IP of Secondary Ingress Controller (South India)"
  type        = string
  default     = "20.219.121.108"
}
