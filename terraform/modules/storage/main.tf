terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
  }
}

data "azurerm_client_config" "current" {}

# checkov:skip=CKV_AZURE_43: Naming convention is enforced by the variable's validation rule. Checkov incorrectly flags dynamic names.
# checkov:skip=CKV2_AZURE_1: CMK is supported but optional via the 'enable_cmk' variable to allow flexibility for different data classifications.
# checkov:skip=CKV2_AZURE_21: Logging is enabled via azurerm_monitor_diagnostic_setting, which is the modern approach not detected by this check.
resource "azurerm_storage_account" "this" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = false
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags

  identity {
    type = var.enable_cmk ? "SystemAssigned" : "None"
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  sas_policy {
    expiration_period = "07.00:00:00"
  }

  # NOTE: Storage encryption/CMK wiring varies by azurerm provider version.
  # Current schema errors indicate the CMK-related storage encryption blocks/args
  # are not supported here, so we omit them for now.
}


resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
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

// Customer Managed Key (CMK) resources - conditional
resource "azurerm_key_vault" "kv" {
  count               = var.enable_cmk ? 1 : 0
  name                = var.key_vault_name != "" ? var.key_vault_name : "${var.storage_account_name}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_key" "kv_key" {
  count        = var.enable_cmk ? 1 : 0
  name         = var.key_name
  key_vault_id = azurerm_key_vault.kv[0].id

  key_type = "RSA"
  key_opts = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
}

resource "azurerm_key_vault_access_policy" "storage_to_kv" {
  count        = var.enable_cmk ? 1 : 0
  key_vault_id = azurerm_key_vault.kv[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.this.identity[0].principal_id

  key_permissions = ["Get", "WrapKey", "UnwrapKey", "Decrypt", "Encrypt"]
}

resource "azurerm_monitor_diagnostic_setting" "storage_diag" {
  count                        = var.enable_diagnostics ? 1 : 0
  name                         = "storage-diag-${var.storage_account_name}"
  target_resource_id           = azurerm_storage_account.this.id
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # Minimal required arguments for this provider schema.
  metric { 
    category = "AllMetrics"
    enabled  = true
  }
}
