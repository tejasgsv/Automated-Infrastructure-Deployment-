# TODO - Fix all Terraform errors

- [x] Run terraform fmt / validate to identify current errors
- [x] Fix terraform module wiring issues (compute: pass admin_public_key)
- [x] Fix compute module outputs (tls_private_key missing)
- [x] Fix storage module encryption block schema (remove/replace unsupported `encryption {}`)
- [x] Fix storage module azurerm_key_vault_key key_opts values (case-sensitive allowed values)
- [x] Re-run `terraform validate` until clean
- [ ] Re-run `terraform init`/`terraform plan` (local and CI-style init) to ensure backend/provider wiring works

- [ ] (Optional) Run tflint/checkov/tfsec

