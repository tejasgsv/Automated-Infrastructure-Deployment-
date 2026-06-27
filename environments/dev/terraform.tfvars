environment             = "dev"
location                = "eastus"
resource_group_name     = "auto-infra-dev-rg"
name_prefix             = "autoinfra"
vnet_address_space      = ["10.20.0.0/16"]
subnet_address_prefixes = ["10.20.1.0/24"]

# REQUIRED by terraform/variables.tf
# Fill these values (or pass them via -var) before running terraform plan/apply.
# Sensitive values are provided via CI environment variables (TF_VAR_*)
# subscription_id and admin_public_key must be set as:
# TF_VAR_subscription_id = ${{ secrets.AZURE_SUBSCRIPTION_ID }}
# TF_VAR_admin_public_key = ${{ secrets.ADMIN_PUBLIC_KEY }}


tags = {
  cost_center = "dev"
  owner       = "platform"
}
