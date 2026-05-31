environment             = "prod"
location                = "eastus"
resource_group_name     = "auto-infra-prod-rg"
name_prefix             = "autoinfra"
vnet_address_space      = ["10.30.0.0/16"]
subnet_address_prefixes = ["10.30.1.0/24"]
tags = {
  cost_center = "prod"
  owner       = "platform"
}