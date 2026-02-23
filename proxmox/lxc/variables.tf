# Proxmox LXC container module variables
# Maintainer:  HybridOps.Studio

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "vm_id" {
  description = "Container ID"
  type        = number
}

variable "hostname" {
  description = "Container hostname"
  type        = string
}

variable "description" {
  description = "Container description"
  type        = string
  default     = "Managed by Terraform"
}

variable "datastore_id" {
  description = "Datastore ID for container root disk"
  type        = string
}

variable "disk_size_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 20
}

variable "cpu_cores" {
  description = "CPU cores"
  type        = number
  default     = 2
}

variable "cpu_architecture" {
  description = "CPU architecture"
  type        = string
  default     = "amd64"
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "swap_mb" {
  description = "Swap size in MB"
  type        = number
  default     = 0
}

variable "unprivileged" {
  description = "Run as unprivileged container"
  type        = bool
  default     = true
}

variable "on_boot" {
  description = "Start container on boot"
  type        = bool
  default     = true
}

variable "started" {
  description = "Start container after creation"
  type        = bool
  default     = true
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
}

variable "vlan_id" {
  description = "Optional VLAN tag for the primary interface"
  type        = number
  default     = null
  nullable    = true
}

variable "ip_address" {
  description = "IPv4 address with CIDR or empty for DHCP"
  type        = string
  default     = ""
}

variable "gateway" {
  description = "IPv4 gateway"
  type        = string
  default     = ""
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = []
}

variable "mac_address" {
  description = "MAC address for primary interface"
  type        = string
  default     = ""
}

variable "template_file_id" {
  description = "LXC template file ID"
  type        = string
}

variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "debian"
}

variable "ssh_public_keys" {
  description = "SSH public keys"
  type        = list(string)
  default     = []
}

variable "initial_password" {
  description = "Initial user password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Container tags"
  type        = list(string)
  default     = []
}
