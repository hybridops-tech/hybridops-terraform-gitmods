# Proxmox VM Multi module (`proxmox/vm-multi`)

Terraform module for provisioning multiple Proxmox VMs with a shared resource profile (CPU, memory, disk, networking) and per-VM metadata.

This module wraps the single-VM module:

- [`proxmox/vm`](../vm/README.md)

and provisions one VM per entry in `vms` using `for_each`.

---

## Module source

Terraform Registry:

```hcl
module "vm_multi" {
  source  = "hybridops-studio/vm-multi/proxmox"
  version = "0.1.0"
}
```

Local source (development):

```hcl
module "vm_multi" {
  source = "../../modules/proxmox/vm-multi"
}
```

---

## Module composition

**Module hierarchy:**

```text
vm-multi (this module)
└── calls: vm (for each VM)
```

---

## Use cases

Appropriate for:

- Kubernetes control-plane nodes
- Kubernetes worker pools
- Homogeneous application server pools
- Small database clusters with consistent sizing

Not appropriate for:

- Single VMs (use [`proxmox/vm`](../vm/README.md))
- Heterogeneous VM fleets with per-VM sizing differences

---

## Requirements

- Terraform `>= 1.5.0`
- Proxmox provider `bpg/proxmox >= 0.69.0`
- Proxmox VE `>= 8.0`
- Template VM to clone (cloud-init enabled for Linux workflows)
- Guest agent recommended for runtime IP discovery outputs

---

## Usage examples

### Linux pool (shared interfaces)

```hcl
module "rke2_control_plane" {
  source  = "hybridops-studio/vm-multi/proxmox"
  version = "0.1.0"

  node_name      = "hybridhub"
  datastore_id   = "local-lvm"
  template_vm_id = 9002

  vms = {
    "rke2-cp-01" = { vm_id = 410, role = "control-plane" }
    "rke2-cp-02" = { vm_id = 411, role = "control-plane" }
    "rke2-cp-03" = { vm_id = 412, role = "control-plane" }
  }

  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 80

  nameservers = ["8.8.8.8"]

  interfaces = [
    {
      bridge  = "vmbr0"
      vlan_id = 10
      ipv4 = {
        address = "dhcp"
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

  tags = ["platform", "rke2", "control-plane", "dev"]
}
```

### Linux pool (per-VM cloud-init)

Per-VM `cloud_init_user_data` overrides the module default.

```hcl
module "generic_linux_pool" {
  source  = "hybridops-studio/vm-multi/proxmox"
  version = "0.1.0"

  node_name      = "hybridhub"
  datastore_id   = "local-lvm"
  template_vm_id = 9000

  vms = {
    "generic-linux-01" = {
      role = "generic"
      cloud_init_user_data = templatefile("${path.module}/cloud-init.yaml.tpl", { hostname = "generic-linux-01" })
    }
    "generic-linux-02" = {
      role = "generic"
      cloud_init_user_data = templatefile("${path.module}/cloud-init.yaml.tpl", { hostname = "generic-linux-02" })
    }
  }

  cpu_cores    = 4
  memory_mb    = 8192
  disk_size_gb = 64

  nameservers = ["8.8.8.8"]

  interfaces = [
    {
      bridge  = "vmbr0"
      vlan_id = 10
      ipv4 = {
        address = "dhcp"
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

  tags = ["platform", "generic", "dev"]
}
```

### Per-VM interface override

Per-VM `interfaces` overrides the module default. Use this for exceptions inside an otherwise homogeneous pool.

```hcl
module "mixed_pool" {
  source  = "hybridops-studio/vm-multi/proxmox"
  version = "0.1.0"

  node_name      = "hybridhub"
  datastore_id   = "local-lvm"
  template_vm_id = 9000

  nameservers = ["8.8.8.8"]

  interfaces = [
    {
      bridge  = "vmbr0"
      vlan_id = 10
      ipv4 = {
        address = "dhcp"
        gateway = "10.10.0.1"
      }
    }
  ]

  vms = {
    "vm-a" = { vm_id = 100, role = "generic" }
    "vm-b" = {
      vm_id = 101
      role  = "generic"
      interfaces = [
        {
          bridge  = "vmbr0"
          vlan_id = 10
          ipv4 = {
            address = "dhcp"
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
    }
  }

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 32

  tags = ["platform", "dev"]
}
```

### Windows VM pool (DHCP)

Windows VMs do not use cloud-init networking. NICs are attached, and IP addressing is expected to be provided by DHCP (or configured in-guest post-provisioning).

```hcl
module "windows_workers" {
  source  = "hybridops-studio/vm-multi/proxmox"
  version = "0.1.0"

  node_name      = "hybridhub"
  datastore_id   = "local-lvm"
  template_vm_id = 9100

  os_type = "win10"

  vms = {
    "win-worker-01" = { vm_id = 301, role = "worker" }
    "win-worker-02" = { vm_id = 302, role = "worker" }
    "win-worker-03" = { vm_id = 303, role = "worker" }
  }

  interfaces = [
    {
      bridge  = "vmbr0"
      vlan_id = 20
      ipv4 = {
        address = "dhcp"
      }
    }
  ]

  tags = ["platform", "workers", "windows", "dev"]
}
```

---

## Networking model

### `interfaces`

`interfaces` defines the ordered NIC list for each VM. Index alignment matters:

- `interfaces[0]` => NIC0 / net0 / ip0
- `interfaces[1]` => NIC1 / net1 / ip1
- etc.

Each entry supports:

- `bridge` (required)
- `vlan_id` (optional)
- `mac_address` (optional)
- `ipv4.address` (`"dhcp"` or CIDR)
- `ipv4.gateway` (optional; typically only set on the primary/mgmt NIC)

### Precedence

- Per-VM `vms[*].interfaces` overrides the module-level `interfaces`.
- Per-VM `vms[*].cloud_init_user_data` overrides module-level `cloud_init_user_data`.

---

## Platform-specific behavior

### Linux VMs

Cloud-init applies addressing during first boot when `os_type` is Linux. DNS settings are applied via `nameservers`. Per-interface gateway is taken from `interfaces[*].ipv4.gateway`.

### Windows VMs

Windows does not natively support cloud-init networking. VMs configured with `os_type = "win10"` or `os_type = "win11"`:

- Attach NICs only
- Boot with DHCP by default
- Require post-provisioning configuration for static addressing (or DHCP reservations)

---

## Inputs summary

Refer to `variables.tf` for the authoritative schema.

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `vms` | `map(object(...))` | Yes | VM name → per-VM metadata (e.g., `role`, optional `vm_id`, optional `cloud_init_user_data`, optional `interfaces`). |
| `node_name` | `string` | Yes | Proxmox node name. |
| `datastore_id` | `string` | Yes | Datastore for VM disks. |
| `snippets_datastore_id` | `string` | No | Datastore for cloud-init snippets (default: `local`). |
| `template_vm_id` | `number` | Yes | Template VM ID to clone. |
| `cpu_cores` | `number` | Yes | CPU cores per VM. |
| `cpu_type` | `string` | No | CPU type (default: `host`). |
| `memory_mb` | `number` | Yes | Memory (MB) per VM. |
| `disk_size_gb` | `number` | Yes | Disk size (GB) per VM. |
| `interfaces` | `list(object)` | Yes | Ordered NIC list applied to all VMs unless overridden. |
| `nameservers` | `list(string)` | No | DNS servers (Linux only). |
| `ssh_username` | `string` | No | SSH username (default: `hybridops`). |
| `ssh_keys` | `list(string)` | No | SSH public keys for the guest. |
| `os_type` | `string` | No | Operating system type (default: `l26`). |
| `on_boot` | `bool` | No | Start VM on boot (default: `true`). |
| `tags` | `list(string)` | No | Tags applied to all VMs. |
| `cloud_init_user_data` | `string` | No | Cloud-init user-data YAML (Linux only). |

---

## Outputs

Refer to `outputs.tf` for the authoritative structure. Key outputs typically include:

| Output | Description |
|--------|-------------|
| `vms` | Complete map of all VM outputs keyed by VM name. |
| `vm_ids` | Map of VM IDs keyed by VM name. |
| `vm_names` | List of VM names. |
| `ipv4_addresses` | Map of primary IPv4 addresses keyed by VM name (from guest agent). |
| `ipv4_addresses_all` | Map of all IPv4 addresses keyed by VM name (from guest agent). |
| `mac_addresses` | Map of primary MAC addresses keyed by VM name. |
| `mac_addresses_all` | Map of all MAC addresses keyed by VM name. |
| `node_name` | Proxmox node name. |
| `tags` | Common tags applied to all VMs. |

---

## Registry publication

- Registry: `registry.terraform.io/hybridops-studio/vm-multi/proxmox`
- Source: `github.com/hybridops-studio/terraform-proxmox-vm-multi`
