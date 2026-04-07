# Proxmox Terraform Modules

Terraform modules for provisioning **Proxmox VE** infrastructure.

This repository is the Git source for the Proxmox module set used in HybridOps and can also be consumed independently in Terraform or Terragrunt stacks.

Use it when you want:
- a reusable **single-VM** module
- a reusable **multi-VM** wrapper for homogeneous fleets
- a reusable **LXC** module

Source repository: https://github.com/hybridops-tech/hybridops-terraform-gitmods

If the modules are useful, a GitHub star is appreciated.

This documentation is written to render correctly in both:
- GitHub (monorepo / relative paths)
- Terraform Registry (module pages)

Where practical, links are provided as **Registry + Source + Repository path** so navigation works in either context.

## Modules

| Module | Purpose | Registry | Source | Repo path |
|---|---|---|---|---|
| `vm` | Single Proxmox VM | [`hybridops-studio/vm/proxmox`](https://registry.terraform.io/modules/hybridops-studio/vm/proxmox) | `git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/vm` | [`vm/`](./vm) |
| `vm-multi` | Multiple homogeneous VMs (wraps `vm`) | [`hybridops-studio/vm-multi/proxmox`](https://registry.terraform.io/modules/hybridops-studio/vm-multi/proxmox) | `git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/vm-multi` | [`vm-multi/`](./vm-multi) |
| `lxc` | Single LXC container | [`hybridops-studio/lxc/proxmox`](https://registry.terraform.io/modules/hybridops-studio/lxc/proxmox) | `git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/lxc` | [`lxc/`](./lxc) |

## Start here

- Want a single VM with direct inputs and outputs? Start with [`vm/`](./vm).
- Want to stamp out multiple similar VMs from one input map? Start with [`vm-multi/`](./vm-multi).
- Want a Proxmox container instead of a VM? Start with [`lxc/`](./lxc).

## Relationships

```text
vm-multi
└── wraps: vm

```

## Platform-specific behavior

Windows guests do not support cloud-init networking. When `os_type` is `win10` or `win11`, inputs such as `ip_address`, `gateway`, and `nameservers` are ignored and the guest boots with DHCP. Static IP configuration is expected to be applied post-provisioning or via DHCP reservations.

## Version compatibility

- Terraform `>= 1.5.0`
- Proxmox provider: `bpg/proxmox`
- Proxmox VE: `>= 8.0`
- Windows networking: see `vm` / `vm-multi` module READMEs (cloud-init networking is not supported on Windows guests).

## HyOps pack source convention (to avoid module source conflicts)

Use one explicit module source per HyOps pack, pinned by tag (preferred) or commit:

```hcl
module_source = "git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/<module>?ref=<tag>"
```

Examples:
- `//proxmox/vm`
- `//proxmox/vm-multi`
- `//proxmox/lxc`

## Documentation convention

Each module directory provides:
- `README.md` for usage and examples
- `variables.tf` for inputs
- `outputs.tf` for outputs
- `versions.tf` for required provider constraints (if used)
