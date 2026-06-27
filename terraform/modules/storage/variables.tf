variable "resource_group_name" {
  description = "Resource group that hosts the storage account."
  type        = string
}

variable "location" {
  description = "Azure region for the storage resources."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID used for the storage private endpoint."
  type        = string
}

variable "vnet_id" {
  description = "Virtual network ID used for the private DNS link."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique storage account name."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 characters, lowercase letters and numbers only"
  }
}

variable "container_name" {
  description = "Blob container name."
  type        = string
}

variable "account_tier" {
  description = "Storage account tier."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication."
  type        = string
  default     = "GRS"
}

variable "private_endpoint_name" {
  description = "Name of the storage private endpoint."
  type        = string
  default     = "storage-pe"
}

variable "tags" {
  description = "Tags applied to storage resources."
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Azure tenant id for Key Vault and access policies."
  type        = string
  default     = ""
}

variable "key_vault_name" {
  description = "Name for Key Vault used for CMK."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Key name inside Key Vault."
  type        = string
  default     = "storage-key"
}



variable "enable_cmk" {
  description = "Enable customer managed key (CMK) for the storage account."
  type        = bool
  default     = false
}



variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to send diagnostics to."
  type        = string
  default     = null
}

// Note: CMK and monitoring variables retained for future branch, but CMK is disabled by default.