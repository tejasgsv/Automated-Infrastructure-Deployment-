resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

locals {
  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
  })

  name_suffix               = random_string.suffix.result
  vnet_name                 = "${var.name_prefix}-${var.environment}-vnet"
  subnet_name               = "${var.name_prefix}-${var.environment}-subnet"
  storage_container_name    = "artifacts"
  log_analytics_name        = "${var.name_prefix}-${var.environment}-law"
  application_insights_name = "${var.name_prefix}-${var.environment}-appi"
  vm_name                   = "${var.name_prefix}-${var.environment}-vm"
  network_interface_name    = "${var.name_prefix}-${var.environment}-nic"
  storage_account_name      = substr(lower(replace("${var.name_prefix}${var.environment}${local.name_suffix}sa", "-", "")), 0, 24)
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

module "network" {
  source = "./modules/network"

  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  vnet_name               = local.vnet_name
  subnet_name             = local.subnet_name
  address_space           = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes
  tags                    = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  subnet_id                  = module.network.subnet_id
  vnet_id                    = module.network.vnet_id
  storage_account_name       = local.storage_account_name
  container_name             = local.storage_container_name

  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name          = azurerm_resource_group.this.name
  location                     = var.location
  log_analytics_workspace_name = local.log_analytics_name
  application_insights_name    = local.application_insights_name
  retention_in_days            = var.log_analytics_retention_in_days
  tags                         = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  resource_group_name    = azurerm_resource_group.this.name
  location               = var.location
  vm_name                = local.vm_name
  network_interface_name = local.network_interface_name
  subnet_id              = module.network.subnet_id
  admin_username         = var.admin_username
  admin_public_key       = var.admin_public_key
  vm_size                = var.vm_size
  tags                   = local.common_tags
}
