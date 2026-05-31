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
  default     = "ZRS"
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