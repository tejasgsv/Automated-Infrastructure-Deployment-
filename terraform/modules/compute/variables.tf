variable "resource_group_name" {
  description = "Resource group that hosts the VM resources."
  type        = string
}

variable "location" {
  description = "Azure region for compute resources."
  type        = string
}

variable "vm_name" {
  description = "Name of the Linux virtual machine."
  type        = string
}

variable "network_interface_name" {
  description = "Name of the network interface."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID used by the VM NIC."
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
}

variable "vm_size" {
  description = "SKU used for the VM."
  type        = string
}

variable "tags" {
  description = "Tags applied to compute resources."
  type        = map(string)
  default     = {}
}