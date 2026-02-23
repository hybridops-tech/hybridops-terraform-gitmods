# Proxmox LXC container module
# Maintainer:   HybridOps.Studio

resource "proxmox_virtual_environment_container" "lxc" {
  description = var.description
  node_name   = var.node_name
  vm_id       = var.vm_id

  tags          = var.tags
  unprivileged  = var.unprivileged
  start_on_boot = var.on_boot
  started       = var.started

  cpu {
    architecture = var.cpu_architecture
    cores        = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
    swap      = var.swap_mb
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size_gb
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  initialization {
    hostname = var.hostname

    dynamic "dns" {
      for_each = length(var.dns_servers) > 0 ? [1] : []
      content {
        servers = var.dns_servers
      }
    }

    dynamic "ip_config" {
      for_each = var.ip_address != "" ? [1] : []
      content {
        ipv4 {
          address = var.ip_address
          gateway = var.gateway
        }
      }
    }

    dynamic "user_account" {
      for_each = (length(var.ssh_public_keys) > 0 || var.initial_password != "") ? [1] : []
      content {
        keys     = var.ssh_public_keys
        password = var.initial_password
      }
    }
  }

  network_interface {
    name        = "eth0"
    bridge      = var.network_bridge
    vlan_id     = var.vlan_id
    mac_address = var.mac_address != "" ? var.mac_address : null
  }
}
