# Proxmox LXC container module outputs
# Maintainer:  HybridOps.Studio

output "vm_id" {
  description = "Container ID"
  value       = proxmox_virtual_environment_container.lxc.vm_id
}

output "hostname" {
  description = "Container hostname"
  value       = proxmox_virtual_environment_container.lxc.initialization[0].hostname
}

output "ip_address" {
  description = "Configured IPv4 address"
  value       = var.ip_address
}

output "mac_address" {
  description = "MAC address of primary interface"
  value = try(
    proxmox_virtual_environment_container.lxc.network_interface[0].mac_address,
    null
  )
}

output "vlan_id" {
  description = "Configured VLAN tag for the primary interface (null when unset)"
  value       = var.vlan_id
}

output "tags" {
  description = "Container tags"
  value       = proxmox_virtual_environment_container.lxc.tags
}

output "started" {
  description = "Container started state"
  value       = proxmox_virtual_environment_container.lxc.started
}

output "node_name" {
  description = "Proxmox node name"
  value       = proxmox_virtual_environment_container.lxc.node_name
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
