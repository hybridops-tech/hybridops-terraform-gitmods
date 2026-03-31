# purpose: Outputs for Proxmox VM module.
# architecture decision: N/A
# maintainer: HybridOps.Tech

output "vm_id" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "node_name" {
  description = "Proxmox node name"
  value       = proxmox_virtual_environment_vm.vm.node_name
}

output "interfaces_configured" {
  description = "Configured NIC list"
  value       = var.interfaces
}

output "ipv4_address_configured_primary" {
  description = "Configured IPv4 address for primary NIC (CIDR or dhcp)"
  value       = try(var.interfaces[0].ipv4.address, null)
}

output "ipv4_addresses" {
  description = "Actual IPv4 addresses reported by guest agent"
  value       = try(proxmox_virtual_environment_vm.vm.ipv4_addresses, [])
}

output "ipv4_address" {
  description = "Primary IPv4 address (first non-loopback)"
  value = try(
    [for ip in proxmox_virtual_environment_vm.vm.ipv4_addresses : ip if !startswith(ip, "127.")][0],
    null
  )
}

output "mac_address_primary" {
  description = "Primary MAC address (configured if set, else from resource)"
  value = coalesce(
    try(var.interfaces[0].mac_address, null),
    try(proxmox_virtual_environment_vm.vm.network_device[0].mac_address, null)
  )
}

output "mac_addresses" {
  description = "All MAC addresses from resource"
  value       = [for net in proxmox_virtual_environment_vm.vm.network_device : net.mac_address]
}

output "cpu_cores" {
  description = "CPU cores"
  value       = var.cpu_cores
}

output "memory_mb" {
  description = "Memory in MB"
  value       = var.memory_mb
}

output "disk_gb" {
  description = "Disk size in GB"
  value       = var.disk_size_gb
}

output "tags" {
  description = "VM tags"
  value       = proxmox_virtual_environment_vm.vm.tags
}

output "status" {
  description = "VM started state"
  value       = proxmox_virtual_environment_vm.vm.started
}

output "os_type" {
  description = "Operating system type"
  value       = var.os_type
}

output "is_windows" {
  description = "Whether this is a Windows VM"
  value       = local.is_windows
}
