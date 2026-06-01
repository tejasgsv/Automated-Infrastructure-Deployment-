terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
  }
}

resource "azurerm_storage_account" "this" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = false
  identity {
    type = "SystemAssigned"
  }
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags

  blob_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }
  }

  sas_policy {
    expiration_period = "07.00:00:00"
  }
}

resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_log_analytics_workspace" "la" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_enabled         = true
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
  tags = var.tags
}

resource "azurerm_key_vault_key" "kv_key" {
  name         = var.key_name
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
}

resource "azurerm_key_vault_access_policy" "storage_to_kv" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_storage_account.this.identity[0].principal_id

  key_permissions = [
    "get",
    "wrapKey",
    "unwrapKey",
  ]
}

resource "azurerm_storage_account_customer_managed_key" "cmk" {
  storage_account_id = azurerm_storage_account.this.id
  key_vault_key_id   = azurerm_key_vault_key.kv_key.id
  depends_on         = [azurerm_key_vault_access_policy.storage_to_kv]
}

resource "azurerm_monitor_diagnostic_setting" "storage_diag" {
  name                       = "storage-diag-${var.storage_account_name}"
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id

  log {
    category = "StorageRead"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  log {
    category = "StorageWrite"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  log {
    category = "StorageDelete"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  metric {
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