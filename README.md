# azure-landing-zone-lab

A hands-on lab for building a small **Azure landing zone** with **Terraform**, **GitHub Actions** and **PowerShell/Python**, following the same practices used in real platform teams. Every change goes through an issue, a feature branch and a reviewed pull request.

> **Status:** Terraform remote state is in place, and the `dev` environment deploys its networking (VNet, subnet, NSG) through the first reusable module. Next up: architecture decision records and the PowerShell bootstrap script.

## Goals

- Infrastructure as Code with Terraform (`azurerm` provider) for Azure
- Secure remote state with Entra ID authentication, locking and versioning
- CI/CD with GitHub Actions and OIDC (no client secrets)
- Security gates: secret scanning, linting and tests
- Tooling in PowerShell and Python, with Pester and pytest

## Architecture (current)

```mermaid
flowchart LR
    subgraph Local["Developer machine"]
        TF["Terraform<br/>infra/environments/dev"]
        BH["backend.hcl<br/>(local, git-ignored)"]
    end
    subgraph Azure["Azure subscription (Switzerland North)"]
        subgraph RGS["rg-tfstate-shared (bootstrap)"]
            SA["Storage account<br/>shared key disabled, TLS 1.2,<br/>versioning, soft delete"]
            C["Container: tfstate<br/>dev.terraform.tfstate"]
        end
        subgraph RGD["rg-lab-dev (Terraform, module.network)"]
            subgraph VNET["vnet-lab-dev 10.10.0.0/16"]
                SNET["snet-workload<br/>10.10.1.0/24"]
            end
            NSG["nsg-workload-dev<br/>default rules only"]
        end
    end
    BH --> TF
    TF -- "state read/write<br/>Entra ID auth + lease lock" --> C
    SA --- C
    TF -- "deploys" --> RGD
    NSG -.-|associated| SNET
```

**State backend:** The storage account that holds the Terraform state is bootstrapped once with the Azure CLI. It cannot be created by the Terraform configuration that uses it as its backend. Hardening:
- Shared key access is disabled, so authentication works only through Entra ID.
- Minimum TLS 1.2 and HTTPS only.
- No public blob access.
- Blob versioning, plus soft delete for blobs and containers (14 days).
- Access is granted through `Storage Blob Data Contributor`, scoped to the storage account only.

## Repository structure

```
.
├── .github/
│   ├── CODEOWNERS
│   └── workflows/              # GitHub Actions (planned)
├── docs/                       # Documentation, diagrams, ADRs
├── infra/
│   ├── environments/
│   │   └── dev/                # Root module for the dev environment
│   └── modules/                # Reusable Terraform modules
│       └── network/            # VNet, subnet, NSG
├── scripts/
│   ├── powershell/             # PowerShell tooling (planned)
│   └── python/                 # Python tooling (planned)
├── .gitattributes              # LF line endings for all text files
├── .gitignore
└── .pre-commit-config.yaml     # gitleaks secret scanning
```

## Modules

### `network`

Path: `infra/modules/network`. Creates a virtual network with one subnet and a network security group (NSG) associated with that subnet. The resource group is not created by the module; it is passed in by the caller.

**Inputs** (all required, no defaults)

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Existing resource group for all network resources |
| `location` | `string` | Azure region |
| `tags` | `map(string)` | Tags applied to every resource |
| `vnet_name` | `string` | Name of the virtual network |
| `vnet_address_space` | `string` | VNet address space in CIDR notation, validated |
| `subnet_name` | `string` | Name of the subnet |
| `subnet_address_prefix` | `string` | Subnet prefix in CIDR notation, validated, must lie within the VNet |
| `nsg_name` | `string` | Name of the NSG |

**Outputs**

| Name | Description |
|------|-------------|
| `vnet_id` | Resource ID of the virtual network |
| `subnet_ids` | Map of subnet IDs, keyed by subnet name |

**Usage** (from `infra/environments/dev/main.tf`)

```hcl
module "network" {
  source = "../../modules/network"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  tags                = local.tags

  vnet_name             = "vnet-${var.workload}-${var.environment}"
  vnet_address_space    = "10.10.0.0/16"
  subnet_name           = "snet-workload"
  subnet_address_prefix = "10.10.1.0/24"
  nsg_name              = "nsg-workload-${var.environment}"
}
```

The NSG has no custom rules yet. The Azure default rules apply, so inbound traffic from the internet is denied.

## Getting started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.9
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [pre-commit](https://pre-commit.com/) and [gitleaks](https://github.com/gitleaks/gitleaks)
- An Azure subscription and the role `Storage Blob Data Contributor` on the state storage account

### First-time setup

```bash
git clone git@github.com:EminEminEmin92/azure-landing-zone-lab.git
cd azure-landing-zone-lab
pre-commit install            # activates secret scanning for this clone
az login
```

### Working with the dev environment

```bash
cd infra/environments/dev
cp backend.hcl.example backend.hcl                              # then set storage_account_name
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv) # never committed
terraform init -backend-config=backend.hcl
terraform plan
```

Real values (subscription ID, storage account name) never live in the repository. They come from the local `backend.hcl` (git-ignored) and from environment variables.

## Conventions

- **Branches:** `feat/`, `fix/`, `docs/`, `chore/`. Nothing is committed directly to `main`.
- **Commits and PR titles:** [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`).
- **Pull requests:** What, Why, How tested, linked to an issue (`Closes #N`), squash-merged.
- **`main` is protected:** PR required, linear history, no force pushes, no deletion.
- **Naming:** `rg-<workload>-<env>`, `vnet-<workload>-<env>`, `snet-<name>`.
- **Region:** `switzerlandnorth`.
- **Mandatory tags:** `workload`, `environment`, `managed_by`.

## Security

- **Secret scanning:** gitleaks runs as a pre-commit hook. It was verified with a fake Entra ID client secret, and the commit was blocked.
- **Git-ignored files:** `*.tfstate`, `*.tfvars` and `backend.hcl`.
- **Commit email:** commits use the GitHub noreply address.
- **Sensitive outputs:** root outputs that contain Azure resource IDs (`vnet_id`, `subnet_ids`) are marked `sensitive`, because the IDs include the subscription ID. This only hides them in the CLI output; they are still stored in the remote state.
- **CI/CD (planned):** authentication through OIDC / workload identity federation, without client secrets.

## Roadmap

**Done**
- Repository setup, branch protection, `.gitignore`, `.gitattributes`
- Secret scanning with gitleaks (pre-commit)
- Remote state backend in Azure (Entra ID auth, locking, versioning)
- `dev` root module with a first resource group
- Reusable networking module (VNet, subnet, NSG), deployed to `dev`

**Next**
- Architecture decision records (ADRs) in `docs/`
- Bootstrap script for the state backend in PowerShell 7 (#8)
- GitHub Actions pipeline: `fmt`/`validate`/`plan` on PRs, `apply` after merge, approval gate for prod, OIDC login
- Security gates: Checkov, PSScriptAnalyzer, Pester, pytest
- Key Vault, storage, VM
- PowerShell and Python tooling with tests
