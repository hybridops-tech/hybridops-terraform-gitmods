# purpose: Provision a Proxmox VM with an ordered NIC list; Linux uses cloud-init initialization.
# architecture decision: N/A
# maintainer: HybridOps.Studio

locals {
  is_windows          = can(regex("^win", var.os_type))
  clone_from_template = var.template_vm_id != null
  indexed_interfaces  = [for idx, nic in var.interfaces : merge(nic, { idx = idx })]
  use_network_data    = trimspace(var.cloud_init_network_data) != ""
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  count = var.cloud_init_user_data != "" && !local.is_windows ? 1 : 0

  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    data      = var.cloud_init_user_data
    file_name = "${var.vm_name}-cloud-init-user.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_network_data" {
  count = var.cloud_init_network_data != "" && !local.is_windows ? 1 : 0

  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    data      = var.cloud_init_network_data
    file_name = "${var.vm_name}-cloud-init-network.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_meta_data" {
  count = var.cloud_init_meta_data != "" && !local.is_windows ? 1 : 0

  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    data      = var.cloud_init_meta_data
    file_name = "${var.vm_name}-cloud-init-meta.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name = var.node_name
  name      = var.vm_name
  vm_id     = var.vm_id
  tags      = var.tags
  on_boot   = var.on_boot

  dynamic "clone" {
    for_each = var.template_vm_id != null ? [1] : []
    content {
      vm_id = var.template_vm_id
      full  = true
    }
  }

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory_mb
  }

  dynamic "disk" {
    for_each = local.clone_from_template ? [] : [1]
    content {
      datastore_id = var.datastore_id
      interface    = "scsi0"
      size         = var.disk_size_gb
      file_format  = "raw"
    }
  }

  # Order is preserved from var.interfaces.
  dynamic "network_device" {
    for_each = local.indexed_interfaces
    content {
      bridge      = network_device.value.bridge
      vlan_id     = lookup(network_device.value, "vlan_id", null)
      mac_address = lookup(network_device.value, "mac_address", null)
    }
  }

  agent {
    enabled = var.guest_agent_enabled
  }

  operating_system {
    type = var.os_type
  }

  dynamic "initialization" {
    for_each = !local.is_windows ? [1] : []
    content {
      datastore_id = var.datastore_id

      # Order is preserved and aligns to net0/ip0, net1/ip1, etc.
      dynamic "ip_config" {
        for_each = local.use_network_data ? [] : local.indexed_interfaces
        content {
          ipv4 {
            address = try(ip_config.value.ipv4.address, "dhcp")

            # Avoid invalid netplan/cloud-init combinations:
            # - Do not set gateway on DHCP interfaces.
            # - Only allow gateway on NIC0 by contract.
            gateway = (
              ip_config.value.idx == 0
              && lower(trimspace(try(ip_config.value.ipv4.address, "dhcp"))) != "dhcp"
            ) ? try(ip_config.value.ipv4.gateway, null) : null
          }
        }
      }

      dynamic "dns" {
        for_each = (!local.use_network_data && length(var.nameservers) > 0) ? [1] : []
        content {
          servers = var.nameservers
        }
      }

      user_account {
        username = var.ssh_username
        keys     = var.ssh_keys
      }

      user_data_file_id    = try(one(proxmox_virtual_environment_file.cloud_init_user_data[*].id), null)
      meta_data_file_id    = try(one(proxmox_virtual_environment_file.cloud_init_meta_data[*].id), null)
      network_data_file_id = try(one(proxmox_virtual_environment_file.cloud_init_network_data[*].id), null)
    }
  }
}
