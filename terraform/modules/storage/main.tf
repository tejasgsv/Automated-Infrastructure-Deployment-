terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
  // CMK, Key Vault and diagnostic resources removed in this minimal safety PR.
  // They will be implemented in a follow-up feature branch with provider-accurate configurations and required secrets/permissions.
  key_vault_key_id   = azurerm_key_vault_key.kv_key[0].id
  depends_on         = [azurerm_key_vault_access_policy.storage_to_kv]
}

resource "azurerm_monitor_diagnostic_setting" "storage_diag" {
  count                      = var.enable_cmk ? 1 : 0
  name                       = "storage-diag-${var.storage_account_name}"
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la[0].id

  logs {
    category = "StorageRead"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  logs {
    category = "StorageWrite"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  logs {
    category = "StorageDelete"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  metrics {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "${var.storage_account_name}-blob-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "blob" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.storage_account_name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}