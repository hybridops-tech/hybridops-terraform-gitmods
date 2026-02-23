# Proxmox LXC Container (`lxc`)

Terraform module for provisioning a single Proxmox LXC container.

This module is a reusable infrastructure primitive (single LXC container).
HyOps can consume it later through a dedicated pack/module path; it is not tied
to any specific IPAM/provider workflow.

## Status

Available for targeted use cases. Platform services are typically deployed on VMs, with application workloads scheduled on Kubernetes.

## Use cases

Appropriate for:
- High-density Linux services with low overhead requirements
- Development and test environments
- Stateless supporting services where kernel sharing is acceptable

Not appropriate for:
- Workloads requiring strong isolation guarantees
- Non-Linux workloads
- Nested virtualization requirements

## Basic usage

```hcl
module "app_container" {
  source = "hybridops-studio/lxc/proxmox"

  node_name    = "hybridhub"
  vm_id        = 300
  hostname     = "app-01"
  datastore_id = "local-lvm"

  cpu_cores    = 2
  memory_mb    = 2048
  disk_size_gb = 20

  template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  os_type          = "ubuntu"

  network_bridge = "vmbr0"
  vlan_id        = 20
  ip_address     = "10.10.0.50/24"
  gateway        = "10.10.0.1"
  dns_servers    = ["8.8.8.8"]

  ssh_public_keys = ["ssh-ed25519 AAAA..."]

  tags = ["dev", "stateless"]
}
```

## Inputs

See `variables.tf` for the complete input specification.

Notable networking inputs:
- `network_bridge` (required)
- `vlan_id` (optional VLAN tag on the primary interface)
- `ip_address` / `gateway` (leave `ip_address = ""` for DHCP)

## Outputs

See `outputs.tf` for available outputs.

## Related modules

- Proxmox VM: [`hybridops-studio/vm/proxmox`](https://registry.terraform.io/modules/hybridops-studio/vm/proxmox)
- Proxmox VM multi: [`hybridops-studio/vm-multi/proxmox`](https://registry.terraform.io/modules/hybridops-studio/vm-multi/proxmox)
- Module index (repository): [`../README.md`](../README.md)

## Git source (umbrella repo)

For direct Git consumption (for example from HyOps packs), use the monorepo with a
subdirectory source:

```hcl
module "app_container" {
  source = "git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/lxc?ref=<tag>"
  # ...
}
```
