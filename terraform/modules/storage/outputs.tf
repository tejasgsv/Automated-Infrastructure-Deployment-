output "storage_account_name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "container_name" {
  description = "Blob container name."
  value       = azurerm_storage_container.this.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace id created for storage diagnostics."
  value       = ""
}

output "key_vault_id" {
  description = "Key Vault id used for CMK."
  value       = ""
}

output "storage_identity_principal_id" {
  description = "Principal id of storage account system-assigned identity."
  value       = azurerm_storage_account.this.identity[0].principal_id
}