# Automated Infrastructure Deployment Pipeline

This repository provides a production-focused, modular Terraform configuration and CI pipeline for provisioning an Azure landing zone. It combines reusable modules, secure remote state management, and automated validation to enable reproducible, auditable infrastructure deployments.

Scope: infrastructure for networking, storage, compute, and monitoring; optional observability via an ELK stack; and GitHub Actions for formatting, validation, policy checks, and security scanning.

Audience: infrastructure engineers and DevOps teams who need a repeatable, secure, and maintainable Azure landing zone deployment.

## What is included

- Modular Terraform for network, storage, compute, and monitoring.
- Azure Monitor via a Log Analytics workspace and Application Insights.
- A Linux VM bootstrapped with Docker so an ELK stack can be deployed on demand.
- GitHub Actions for formatting, validation, policy checks, and manual planning.

## Repository layout

- `terraform/` contains the root configuration and reusable modules.
- `environments/dev` and `environments/prod` hold environment-specific variable files.
- `observability/elk` contains a Docker Compose stack for Elasticsearch, Logstash, and Kibana.
- `.github/workflows/terraform.yml` runs Terraform validation and security scanning.

## Architecture

This repository provisions an Azure landing zone using Terraform with a modular layout:

- Root configuration: orchestration, variables, provider and outputs in the `terraform` folder.
- Modules: `network`, `storage`, `compute`, and `monitoring` under `terraform/modules`.
- Remote state backend: Azure Storage account + container (configured at init-time).
- CI: GitHub Actions runs formatting, validation, policy/security checks, and manual plan.
- Observability: optional ELK compose in `observability/elk` for self-hosted logs.

## Commands (no helper script)

Below are explicit PowerShell and Bash command sequences to initialize the backend, bootstrap container if needed, and run Terraform.

1) Authenticate to Azure

PowerShell:
```powershell
az login
az account set --subscription "<your-subscription-id>"
```

Bash:
```bash
az login
az account set --subscription "<your-subscription-id>"
```

2) Create or verify the backend Storage container (bootstrap if missing)

PowerShell:
```powershell
$rg = "<backend-resource-group>"
$acct = "<backend-storage-account>"
$container = "terraform-state"
az storage container show --auth-mode login --account-name $acct --name $container || az storage container create --auth-mode login --account-name $acct --name $container
```

Bash:
```bash
RG=<backend-resource-group>
ACCT=<backend-storage-account>
CONTAINER=terraform-state
az storage container show --auth-mode login --account-name $ACCT --name $CONTAINER || az storage container create --auth-mode login --account-name $ACCT --name $CONTAINER
```

3) Option A — Initialize Terraform using Azure AD (recommended)

PowerShell:
```powershell
cd terraform
terraform init -reconfigure -backend-config="resource_group_name=<backend-resource-group>" -backend-config="storage_account_name=<backend-storage-account>" -backend-config="container_name=terraform-state" -backend-config="key=terraform.tfstate" -backend-config="subscription_id=<your-subscription-id>"
```

Bash:
```bash
cd terraform
terraform init -reconfigure \
	-backend-config="resource_group_name=<backend-resource-group>" \
	-backend-config="storage_account_name=<backend-storage-account>" \
	-backend-config="container_name=terraform-state" \
	-backend-config="key=terraform.tfstate" \
	-backend-config="subscription_id=<your-subscription-id>"
```

4) Option B — Initialize Terraform using a storage account key (when Azure AD blob RBAC is not available)

PowerShell:
```powershell
$acct = "<backend-storage-account>"
$rg = "<backend-resource-group>"
$key = az storage account keys list -g $rg -n $acct --query "[0].value" -o tsv
cd terraform
terraform init -reconfigure -backend-config="resource_group_name=$rg" -backend-config="storage_account_name=$acct" -backend-config="container_name=terraform-state" -backend-config="key=terraform.tfstate" -backend-config="access_key=$key" -backend-config="subscription_id=<your-subscription-id>"
```

Bash:
```bash
ACCT=<backend-storage-account>
RG=<backend-resource-group>
KEY=$(az storage account keys list -g $RG -n $ACCT --query "[0].value" -o tsv)
cd terraform
terraform init -reconfigure \
	-backend-config="resource_group_name=$RG" \
	-backend-config="storage_account_name=$ACCT" \
	-backend-config="container_name=terraform-state" \
	-backend-config="key=terraform.tfstate" \
	-backend-config="access_key=$KEY" \
	-backend-config="subscription_id=<your-subscription-id>"
```

5) Validate, plan, apply

PowerShell / Bash (from the `terraform` directory):
```powershell
terraform fmt -recursive
terraform validate
terraform plan -var-file="../environments/dev/terraform.tfvars" -var "subscription_id=<your-subscription-id>"
terraform apply -var-file="../environments/dev/terraform.tfvars" -var "subscription_id=<your-subscription-id>"
```

Alternative: set `TF_VAR_subscription_id` env var and omit `-var`:
```powershell
$env:TF_VAR_subscription_id = "<your-subscription-id>"
terraform plan -var-file="../environments/dev/terraform.tfvars"
```

CI notes

- GitHub Actions workflows in `.github/workflows/terraform.yml` can inject the same `-backend-config` values or use secrets for the storage account key.
- Prefer Azure AD RBAC for runners where possible; otherwise inject `access_key` from CI secrets.

## Notes

- The backend Storage account and container must exist (or be created) before `terraform init` succeeds.
- Keep the storage account key secret; prefer Azure AD RBAC when possible.


## Observability

The Terraform configuration provisions Azure Monitor primitives. The ELK stack is provided as a Docker Compose template for workloads that need self-managed log aggregation and visualization.

## Notes

- The backend is configured for Azure Storage, but the concrete storage account settings are supplied at init time.
- The Azure storage account and container must already exist before `terraform init` can complete successfully.
- If Azure AD blob permissions are not available, set `TF_BACKEND_ACCESS_KEY` and the init helper will use key-based backend auth.
- `subscription_id` is passed as a Terraform variable and can also be sourced from Azure environment variables in CI.
- GitHub Actions uses the same backend bootstrap script, so local and CI initialization stay aligned.