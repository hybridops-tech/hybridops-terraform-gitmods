# Proxmox VM module (`proxmox/vm`)

Terraform module for provisioning a single Proxmox VM from a template. Supports Linux (cloud-init) and Windows (DHCP/guest-managed networking), with an ordered multi-interface networking contract.

## Module composition

Standalone module. For multiple VMs, instantiate this module with caller-side `for_each`.

## Registry publication

- **Registry:** `registry.terraform.io/hybridops-studio/vm/proxmox`
- **Source:** `github.com/hybridops-studio/terraform-proxmox-vm`

## Use cases

Appropriate for:
- Individually significant VMs (control nodes, databases, core services)
- Workloads requiring VM-specific sizing or metadata
- Bootstrap infrastructure that must exist before NetBox is available

Not appropriate for:
- None. For homogeneous pools, use this module with caller-side `for_each`.

## Module reference

Terraform Registry:

```hcl
module "vm" {
  source  = "hybridops-studio/vm/proxmox"
  version = "0.1.0"
}
```

Local source (development):

```hcl
module "vm" {
  source = "../../modules/proxmox/vm"
}
```

## Multiple VMs

Use caller-side `for_each` to provision a VM pool with this module:

```hcl
module "pool" {
  source  = "hybridops-studio/vm/proxmox"
  version = "0.1.0"

  for_each = var.vms

  node_name      = var.node_name
  datastore_id   = var.datastore_id
  template_vm_id = var.template_vm_id

  vm_name = each.key
  vm_id   = try(each.value.vm_id, null)

  cpu_cores    = var.cpu_cores
  memory_mb    = var.memory_mb
  disk_size_gb = var.disk_size_gb

  interfaces = try(each.value.interfaces, var.interfaces)

  tags = concat(var.tags, [each.value.role])
}
```

## Requirements

- Terraform `>= 1.5.0`
- Proxmox provider `bpg/proxmox >= 0.69.0`
- Proxmox VE `>= 8.0`
- Template VM to clone (cloud-init enabled for Linux workflows)
- Guest agent recommended for runtime IP discovery outputs

## Usage examples

### Linux VM (single interface)

```hcl
module "ctrl_01" {
  source  = "hybridops-studio/vm/proxmox"
  version = "0.1.0"

  node_name      = "hybridhub"
  datastore_id   = "local-lvm"
  template_vm_id = 9002

  vm_id   = 102
  vm_name = "ctrl-01"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 32

  nameservers = ["8.8.8.8"]

  # interfaces[0] => NIC0 (net0 / ip0)
  interfaces = [
    {
      bridge      = "vmbr0"
      vlan_id     = 10
      mac_address = "BC:24:11:00:00:11"
      ipv4 = {
        address = "10.10.0.11/24"
        gateway = "10.10.0.1"
      }
    }
  ]

  cloud_init_user_data = file("${path.module}/cloud-init.yaml")

  tags = ["env:dev", "layer:10-platform", "service:ctrl-01"]
}
```

### Linux VM (multiple interfaces)

Additional NICs are expressed by appending entries to `interfaces`. Index order is stable:

- `interfaces[0]` => NIC0 / ip0
- `interfaces[1]` => NIC1 / ip1
- etc.

Only one NIC should typically carry the default route (`gateway`), usually NIC0.

```hcl
module "eve_ng" {
  source  = "hybridops-studio/vm/proxmox"
  version = "0.1.0"

  node_name      = "hybridhub"
  datastore_id   = "local-lvm"
  template_vm_id = 9000

  vm_id   = 402
  vm_name = "eve-ng"

  cpu_cores    = 6
  memory_mb    = 12288
  disk_size_gb = 150

  nameservers = ["8.8.8.8"]

  interfaces = [
    {
      bridge      = "vmbr0"
      vlan_id     = 10
      mac_address = "BC:24:11:00:00:41"
      ipv4 = {
        address = "10.10.0.41/24"
        gateway = "10.10.0.1"
      }
    },
    {
      bridge  = "vmbr0"
      vlan_id = 50
      ipv4 = {
        address = "dhcp"
      }
    }
  ]

  cloud_init_user_data = file("${path.module}/cloud-init.yaml")

  tags = ["env:dev", "layer:10-platform", "service:eve-ng"]
}
```

### Windows VM (DHCP)

Windows does not use cloud-init networking in this module. The module attaches NICs, and addressing is expected to be provided by DHCP (or configured in-guest post-provisioning).

```hcl
module "win_app_01" {
  source  = "hybridops-studio/vm/proxmox"
  version = "0.1.0"

  node_name      = "hybridhub"
  datastore_id   = "local-lvm"
  template_vm_id = 9100

  vm_id   = 200
  vm_name = "win-app-01"

  os_type = "win10"

  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 80

  interfaces = [
    {
      bridge      = "vmbr0"
      vlan_id     = 10
      mac_address = "BC:24:11:00:00:C8"
      ipv4 = {
        address = "dhcp"
      }
    }
  ]

  tags = ["env:prod", "layer:20-apps", "os:windows"]
}
```

Configure static IPs post-provisioning via orchestration, or use DHCP reservation.

## Network configuration

### `interfaces`

`interfaces` defines the ordered NIC list for the VM. Index alignment matters:

- `interfaces[0]` => NIC0 / net0 / ip0
- `interfaces[1]` => NIC1 / net1 / ip1
- etc.

Each entry supports:

- `bridge` (required)
- `vlan_id` (optional)
- `mac_address` (optional)
- `ipv4.address` (`"dhcp"` or CIDR)
- `ipv4.gateway` (optional; typically only set on the primary/mgmt NIC)

### Platform-specific behavior

#### Linux VMs

When `os_type` is Linux, the module configures Proxmox `initialization.ip_config` for each NIC using `interfaces[*].ipv4`. Cloud-init applies addressing during first boot.

#### Windows VMs

When `os_type` is Windows, the module does not apply Proxmox `initialization` for networking. NICs are attached, and the guest OS is expected to obtain DHCP or be configured post-provisioning.

## Inputs

Refer to [`variables.tf`](./variables.tf) for the authoritative schema. Key inputs:

| Name | Required | Description |
|------|----------|-------------|
| `node_name` | yes | Proxmox node name |
| `vm_name` | yes | VM name |
| `vm_id` | no | VM ID (null => Proxmox assigns next free ID) |
| `template_vm_id` | no | Template VM ID to clone (null => no clone block) |
| `datastore_id` | yes | Datastore for VM disks |
| `snippets_datastore_id` | no | Datastore for cloud-init snippets (default: `local`) |
| `cpu_cores` | no | CPU cores (default: `2`) |
| `cpu_type` | no | CPU type (default: `host`) |
| `memory_mb` | no | Memory in MB (default: `2048`) |
| `disk_size_gb` | no | Disk size in GB (default: `20`) |
| `interfaces` | yes | Ordered NIC list (at least one NIC) |
| `nameservers` | no | DNS servers (Linux only) |
| `ssh_username` | no | SSH username (Linux only) |
| `ssh_keys` | no | SSH public keys (Linux only) |
| `os_type` | no | Proxmox OS type (default: `l26`) |
| `on_boot` | no | Start VM on boot (default: `true`) |
| `tags` | no | VM tags |
| `cloud_init_user_data` | no | Cloud-init user-data YAML (Linux only; empty disables snippet creation) |

## Outputs

Refer to [`outputs.tf`](./outputs.tf) for the authoritative structure. Outputs that rely on runtime discovery require the guest agent.

Typical outputs include:

| Output | Description |
|--------|-------------|
| `vm_id` | Proxmox VM ID |
| `vm_name` | VM name |
| `node_name` | Proxmox node name |
| `ipv4_address` | Primary IPv4 address (first non-loopback, from guest agent) |
| `ipv4_addresses` | All IPv4 addresses reported by guest agent |
| `mac_addresses` | All MAC addresses |
| `tags` | VM tags |
| `status` | VM started state |
| `os_type` | Operating system type |
| `is_windows` | Whether VM is Windows |

## See also

- IPAM-backed allocation (NetBox):
  - [`netbox/vm-with-ipam`](../netbox/vm-with-ipam/README.md)
  - [`netbox/vm-multi-with-ipam`](../netbox/vm-multi-with-ipam/README.md)
