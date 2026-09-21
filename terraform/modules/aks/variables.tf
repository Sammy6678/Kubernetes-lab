variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = null
}

variable "default_node_pool_name" {
  description = "Name of default node pool"
  type        = string
  default     = "systempool"
}

variable "node_count" {
  description = "Initial node count for default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vnet_subnet_id" {
  description = "The ID of the Subnet where the Node Pool will be deployed"
  type        = string
  default     = null
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for default node pool"
  type        = bool
  default     = false
}

variable "min_count" {
  description = "Minimum node count for auto-scaling"
  type        = number
  default     = null
}

variable "max_count" {
  description = "Maximum node count for auto-scaling"
  type        = number
  default     = null
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "network_plugin" {
  description = "Network plugin to use for networking (azure or kubenet)"
  type        = string
  default     = "azure"
}


variable "tags" {
  description = "Tags to apply to AKS resources"
  type        = map(string)
  default     = {}
}
