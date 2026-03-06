# purpose: Inputs for Proxmox multi-VM module.
# architecture decision: N/A
# maintainer: HybridOps.Studio

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "vms" {
  description = "Map of VM names to their configuration"
  type = map(object({
    role                    = string
    vm_id                   = optional(number)
    vm_name                 = optional(string)
    cloud_init_user_data    = optional(string)
    cloud_init_network_data = optional(string)
    cloud_init_meta_data    = optional(string)

    interfaces = optional(list(object({
      bridge      = string
      vlan_id     = optional(number)
      mac_address = optional(string)
      ipv4 = optional(object({
        address = string
        gateway = optional(string)
      }))
    })))
  }))

  validation {
    condition = (
      length(var.interfaces) > 0 ||
      alltrue([
        for _, v in var.vms :
        try(length(v.interfaces), 0) > 0
      ])
    )
    error_message = "Either set module-level interfaces (default for all VMs) or set per-VM interfaces for every VM."
  }
}

variable "interfaces" {
  description = "Default ordered NIC list applied to all VMs unless a VM overrides it."
  type = list(object({
    bridge      = string
    vlan_id     = optional(number)
    mac_address = optional(string)
    ipv4 = optional(object({
      address = string
      gateway = optional(string)
    }))
  }))
  default = []
}

variable "template_vm_id" {
  description = "Template VM ID to clone from"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores per VM"
  type        = number
  default     = 2
}

variable "cpu_type" {
  description = "CPU type"
  type        = string
  default     = "host"
}

variable "memory_mb" {
  description = "Memory in MB per VM"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "Disk size in GB per VM"
  type        = number
  default     = 20
}

variable "guest_agent_enabled" {
  description = "Whether to enable the QEMU guest agent on cloned VMs"
  type        = bool
  default     = true
}

variable "datastore_id" {
  description = "Datastore ID for VM disks"
  type        = string
}

variable "snippets_datastore_id" {
  description = "Datastore for cloud-init snippets"
  type        = string
  default     = "local"
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
  description = "Operating system type"
  type        = string
  default     = "l26"
}

variable "on_boot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common VM tags applied to all VMs"
  type        = list(string)
  default     = []
}

variable "cloud_init_user_data" {
  description = "Cloud-init user data default (Linux only). Per-VM cloud_init_user_data overrides this."
  type        = string
  default     = ""
}

variable "cloud_init_network_data" {
  description = "Cloud-init network-config default (Linux only). Per-VM cloud_init_network_data overrides this."
  type        = string
  default     = ""
}

variable "cloud_init_meta_data" {
  description = "Cloud-init meta-data default (Linux only). Per-VM cloud_init_meta_data overrides this."
  type        = string
  default     = ""
}
