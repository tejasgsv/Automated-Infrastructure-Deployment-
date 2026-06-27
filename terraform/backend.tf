// Temporary for local validation/plan.
// CI pipeline uses the azurerm backend (see .github/workflows/terraform.yml).
// Locally we disable backend because you want to delete the backend storage.
//
// Terraform will use local state in ./terraform/.terraform by default.

