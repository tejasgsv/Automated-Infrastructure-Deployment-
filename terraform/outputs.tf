output "resource_group_name" {
  description = "Resource group created for the deployment."
  value       = azurerm_resource_group.this.name
}

output "virtual_network_id" {
  description = "ID of the deployed virtual network."
  value       = module.network.vnet_id
}

output "subnet_id" {
  description = "ID of the deployed subnet."
  value       = module.network.subnet_id
}

output "storage_account_name" {
  description = "Storage account used for artifacts and adjacent workloads."
  value       = module.storage.storage_account_name
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace used by Azure Monitor."
  value       = module.monitoring.log_analytics_workspace_name
}

output "vm_name" {
  description = "Name of the Linux VM."
  value       = module.compute.vm_name
}