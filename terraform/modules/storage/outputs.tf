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

output "key_vault_id" {
  description = "Key Vault id used for CMK."
  value       = var.enable_cmk ? azurerm_key_vault.kv[0].id : ""
}

output "storage_identity_principal_id" {
  description = "Principal id of storage account system-assigned identity."
  value       = try(azurerm_storage_account.this.identity[0].principal_id, "")
}