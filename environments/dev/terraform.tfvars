environment             = "dev"
location                = "eastus"
resource_group_name     = "auto-infra-dev-rg"
name_prefix             = "autoinfra"
vnet_address_space      = ["10.20.0.0/16"]
subnet_address_prefixes = ["10.20.1.0/24"]
tags = {
  cost_center = "dev"
  owner       = "platform"
}