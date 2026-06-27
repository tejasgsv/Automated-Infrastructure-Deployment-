variable "subscription_id" {
  description = "Azure subscription ID used by the provider and backend configuration."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that hosts the deployment."
  type        = string
  default     = "auto-infra-rg"
}

variable "location" {
  description = "Azure region used for the deployment."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name used for naming and tagging."
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Short prefix used in resource names."
  type        = string
  default     = "autoinfra"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "CIDR blocks assigned to the application subnet."
  type        = list(string)
  default     = ["10.20.1.0/24"]
}

variable "admin_username" {
  description = "Admin username for the Linux virtual machine."
  type        = string
  default     = "azureuser"
}

variable "vm_size" {
  description = "SKU used for the Linux virtual machine."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_public_key" {
  description = "Public SSH key for the admin user on the virtual machine."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default = {
    project = "automated-infrastructure-deployment"
  }
}

variable "log_analytics_retention_in_days" {
  description = "Retention window for the Log Analytics workspace."
  type        = number
  default     = 30
}