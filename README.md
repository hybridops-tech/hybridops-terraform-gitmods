
# HybridOps Terraform Git Modules

Git-sourced Terraform modules for HybridOps Packs, Terragrunt consumption, and internal automation. These modules are not published to the Terraform Registry and are intended for Git-only sourcing via subdirectory paths.

## Overview

This repository provides Terraform modules grouped by provider. Each module is structured for:

- HybridOps Pack integration
- Terragrunt module sourcing
- Native Terraform Git module usage
- HybridOps Academy instructional material

Modules are versioned using Git tags and consumed through Git-based source references.

## Usage

### Terraform
```hcl
module "vm" {
  source = "git::https://github.com/<ORG>/hybridops-terraform-gitmods.git//proxmox/vm?ref=v1.0.0"
}
```

### Terragrunt
```hcl
terraform {
  source = "git::https://github.com/<ORG>/hybridops-terraform-gitmods.git//proxmox/sdn?ref=v1.0.0"
}
```

### HybridOps Pack
```yaml
pack_ref:
  id: proxmox-sdn@v1.0
  source: "git::https://github.com/<ORG>/hybridops-terraform-gitmods.git//proxmox/sdn"
  version: "v1.0.0"
```

Each module includes `main.tf`, `variables.tf`, `outputs.tf`, and a README describing usage, inputs, and outputs.

## Versioning

Modules are tagged using Git, and consumers should reference tags explicitly:

```sh
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

## Repository Structure

Modules are organized by provider. Each subdirectory represents an independent module intended to be consumed via Git-based source paths.

Providers include, but are not limited to:

- `proxmox/`
- `hetzner/`
- `azure/`
- `gcp/`
- `generic/`

## Conventions

- Modules must not include backend or workspace configuration.
- Modules must not embed provider authentication logic.
- Inputs and outputs must be explicitly defined.
- Modules must remain deterministic and self-contained.
- Git source references must be used for consumption.
- Registry metadata is not required.

## Documentation

Each provider folder contains a README outlining its available modules and use cases. Each module exposes a dedicated README with:

- Purpose
- Input variables
- Outputs
- Provider prerequisites
- Example usage

## License

MIT or an alternative license may be applied depending on project requirements.
