variable "resource_group_name" {
  description = "Resource group that hosts the network resources."
  type        = string
}

variable "location" {
  description = "Azure region for the network resources."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "subnet_name" {
  description = "Name of the application subnet."
  type        = string
}

variable "address_space" {
  description = "Virtual network address space."
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "Subnet CIDR blocks."
  type        = list(string)
}

variable "admin_source_address_prefixes" {
  description = "Source address prefixes allowed to reach admin-facing services in the VM subnet."
  type        = list(string)
  default     = ["VirtualNetwork"]
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}