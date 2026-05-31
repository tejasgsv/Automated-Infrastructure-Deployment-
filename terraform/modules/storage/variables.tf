variable "resource_group_name" {
  description = "Resource group that hosts the storage account."
  type        = string
}

variable "location" {
  description = "Azure region for the storage resources."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique storage account name."
  type        = string
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
  default     = "LRS"
}

variable "tags" {
  description = "Tags applied to storage resources."
  type        = map(string)
  default     = {}
}