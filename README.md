# hybridops-terraform-gitmods

Terraform modules for Proxmox VM, multi-VM, and LXC delivery — usable standalone, in Terragrunt stacks, or as part of HybridOps. Distributed via Git rather than the Terraform Registry.

## Modules

| Module | Path | Purpose |
|---|---|---|
| Proxmox VM | `proxmox/vm` | Single VM from a Proxmox template clone — CPU, memory, disk, NICs, tags, guest agent |
| Proxmox VM (multi) | `proxmox/vm-multi` | Batch VM delivery from a shared template — same contract, multiple instances |
| Proxmox LXC | `proxmox/lxc` | LXC container delivery on Proxmox VE 8.x |

Provider: `bpg/proxmox >= 0.69.0` — Terraform `>= 1.5.0`

## Usage

### Terraform

```hcl
module "vm" {
  source = "git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/vm?ref=v1.0.0"

  node_name        = "hybridhub"
  vm_name          = "my-vm"
  template_vm_id   = 9000
  cpu_cores        = 2
  memory_mb        = 2048
  disk_size_gb     = 32
}
```

```hcl
module "lxc" {
  source = "git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/lxc?ref=v1.0.0"

  node_name = "hybridhub"
}
```

### Terragrunt

```hcl
terraform {
  source = "git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/vm?ref=v1.0.0"
}

inputs = {
  node_name      = "hybridhub"
  vm_name        = "my-vm"
  template_vm_id = 9000
}
```

### HybridOps pack reference

```yaml
pack_ref:
  id: proxmox-vm@v1.0
  source: "git::https://github.com/hybridops-tech/hybridops-terraform-gitmods.git//proxmox/vm"
  version: "v1.0.0"
```

## Versioning

Modules are tagged together at the repository level. Pin to a tag for stable consumption:

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

Reference the tag via `?ref=<tag>` in all source strings.

## Conventions

- No backend or workspace configuration inside modules.
- No provider authentication logic inside modules.
- All inputs and outputs explicitly defined.
- Modules are deterministic and self-contained.
- Distributed via Git tag — reference a tag with `?ref=<tag>` for stable, reproducible consumption.

## Related

- [terraform-proxmox-sdn](https://registry.terraform.io/modules/hybridops-tech/sdn/proxmox) — Proxmox SDN zone, VNet, and DHCP delivery (Registry-published)
- [HybridOps Core](https://github.com/hybridops-tech/hybridops-core) — the runtime that consumes these modules via packs and blueprints
- [Docs](https://docs.hybridops.tech)

## License

[MIT-0](https://spdx.org/licenses/MIT-0.html)
