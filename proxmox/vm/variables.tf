# purpose: Inputs for Proxmox VM module.
# architecture decision: N/A
# maintainer: HybridOps.Studio

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "vm_id" {
  description = "VM ID. If null, Proxmox assigns the next free ID."
  type        = number
  default     = null
}

variable "template_vm_id" {
  description = "Template VM ID to clone from"
  type        = number
  default     = null
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "cpu_type" {
  description = "CPU type"
  type        = string
  default     = "host"
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "datastore_id" {
  description = "Datastore ID for VM disks"
  type        = string
}

variable "interfaces" {
  description = "Ordered NIC list. Index alignment matters: interfaces[0] is net0/ip0, interfaces[1] is net1/ip1, etc."
  type = list(object({
    bridge      = string
    vlan_id     = optional(number)
    mac_address = optional(string)
    ipv4 = optional(object({
      address = string
      gateway = optional(string)
    }))
  }))

  validation {
    condition     = var.interfaces != null && length(var.interfaces) > 0
    error_message = "interfaces must contain at least one NIC."
  }

  validation {
    condition = (
      lower(trimspace(try(var.interfaces[0].ipv4.address, "dhcp"))) == "dhcp"
      || try(var.interfaces[0].ipv4.gateway, null) != null
    )
    error_message = "interfaces[0].ipv4.gateway is required when interfaces[0].ipv4.address is static (not dhcp)."
  }

  validation {
    condition = length([
      for idx, nic in var.interfaces : idx
      if try(nic.ipv4.gateway, null) != null && idx != 0
    ]) == 0
    error_message = "Only interfaces[0] may define ipv4.gateway. Do not set gateways on additional NICs."
  }
}

variable "nameservers" {
  description = "DNS nameservers (Linux cloud-init only)"
  type        = list(string)
  default     = []
}

variable "ssh_username" {
  description = "SSH username (Linux cloud-init only)"
  type        = string
  default     = "hybridops"
}

variable "ssh_keys" {
  description = "SSH public keys (Linux cloud-init only)"
  type        = list(string)
  default     = []
}

variable "os_type" {
  description = "Operating system type (l26 for Linux, win10/win11 for Windows)"
  type        = string
  default     = "l26"
}

variable "tags" {
  description = "VM tags"
  type        = list(string)
  default     = []
}

variable "on_boot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}

variable "cloud_init_user_data" {
  description = "Cloud-init user data (Linux only)"
  type        = string
  default     = ""
}

variable "snippets_datastore_id" {
  description = "Datastore for cloud-init snippets"
  type        = string
  default     = "local"
}
