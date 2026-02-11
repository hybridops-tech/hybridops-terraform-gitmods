# Proxmox Terraform Modules

Terraform modules for provisioning Proxmox VE infrastructure.

This documentation is written to render correctly in both:
- GitHub (monorepo / relative paths)
- Terraform Registry (module pages)

Where practical, links are provided as **Registry + Source + Repository path** so navigation works in either context.

## Modules

| Module | Purpose | Registry | Source | Repo path |
|---|---|---|---|---|
| `vm` | Single Proxmox VM | [`hybridops-studio/vm/proxmox`](https://registry.terraform.io/modules/hybridops-studio/vm/proxmox) | `github.com/hybridops-studio/terraform-proxmox-vm` | [`vm/`](./vm) |
| `lxc` | Single LXC container | [`hybridops-studio/lxc/proxmox`](https://registry.terraform.io/modules/hybridops-studio/lxc/proxmox) | `github.com/hybridops-studio/terraform-proxmox-lxc` | [`lxc/`](./lxc) |
| `vm-with-ipam` | Single VM with NetBox IPAM | [`hybridops-studio/vm-with-ipam/proxmox`](https://registry.terraform.io/modules/hybridops-studio/vm-with-ipam/proxmox) | `github.com/hybridops-studio/terraform-proxmox-vm-with-ipam` | [`netbox/vm-with-ipam/`](./netbox/vm-with-ipam) |
| `vm-multi-with-ipam` | Multiple VMs with NetBox IPAM (wraps `vm-with-ipam`) | [`hybridops-studio/vm-multi-with-ipam/proxmox`](https://registry.terraform.io/modules/hybridops-studio/vm-multi-with-ipam/proxmox) | `github.com/hybridops-studio/terraform-proxmox-vm-multi-with-ipam` | [`netbox/vm-multi-with-ipam/`](./netbox/vm-multi-with-ipam) |

## Relationships

```text
vm-multi-with-ipam
└── wraps: vm-with-ipam
```

For multiple non-IPAM VMs, use `proxmox/vm` with caller-side `for_each`.

## Platform-specific behavior

Windows guests do not support cloud-init networking. When `os_type` is `win10` or `win11`, inputs such as `ip_address`, `gateway`, and `nameservers` are ignored and the guest boots with DHCP. Static IP configuration is expected to be applied post-provisioning or via DHCP reservations.

## Version compatibility

- Terraform `>= 1.5.0`
- Proxmox provider: `bpg/proxmox`
- NetBox provider: `e-breuninger/netbox` (IPAM modules only)
- Proxmox VE: `>= 8.0`
- Windows networking: see `vm` module README (cloud-init networking is not supported on Windows guests).

## Documentation convention

Each module directory provides:
- `README.md` for usage and examples
- `variables.tf` for inputs
- `outputs.tf` for outputs
- `versions.tf` for required provider constraints (if used)
