# purpose: Outputs for Proxmox multi-VM module.
# architecture decision: N/A
# maintainer: HybridOps.Tech

output "vms" {
  description = "Complete map of all VM outputs"
  value = {
    for name, vm in module.vm : name => {
      vm_id     = vm.vm_id
      vm_name   = vm.vm_name
      node_name = vm.node_name

      interfaces_configured   = vm.interfaces_configured
      ipv4_configured_primary = vm.ipv4_address_configured_primary

      ipv4_address   = vm.ipv4_address
      ipv4_addresses = vm.ipv4_addresses

      mac_address_primary = vm.mac_address_primary
      mac_addresses       = vm.mac_addresses

      cpu_cores = vm.cpu_cores
      memory_mb = vm.memory_mb
      disk_gb   = vm.disk_gb

      tags       = vm.tags
      status     = vm.status
      os_type    = vm.os_type
      is_windows = vm.is_windows
    }
  }
}

output "vm_ids" {
  description = "Map of VM IDs keyed by VM name"
  value       = { for name, vm in module.vm : name => vm.vm_id }
}

output "vm_names" {
  description = "List of VM names"
  value       = keys(module.vm)
}

output "ipv4_configured_primary" {
  description = "Map of configured primary IPv4 addresses keyed by VM name"
  value       = { for name, vm in module.vm : name => vm.ipv4_address_configured_primary }
}

output "ipv4_addresses" {
  description = "Map of primary actual IPv4 addresses (from guest agent) keyed by VM name"
  value       = { for name, vm in module.vm : name => vm.ipv4_address }
}

output "ipv4_addresses_all" {
  description = "Map of all IPv4 addresses keyed by VM name"
  value       = { for name, vm in module.vm : name => vm.ipv4_addresses }
}

output "mac_addresses_primary" {
  description = "Map of primary MAC addresses keyed by VM name"
  value       = { for name, vm in module.vm : name => vm.mac_address_primary }
}

output "mac_addresses_all" {
  description = "Map of all MAC addresses keyed by VM name"
  value       = { for name, vm in module.vm : name => vm.mac_addresses }
}

output "node_name" {
  description = "Proxmox node name"
  value       = var.node_name
}

output "tags" {
  description = "Common tags applied to all VMs"
  value       = var.tags
}
