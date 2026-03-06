# purpose: Provision multiple Proxmox VMs using the vm module, with default or per-VM NIC lists.
# architecture decision: N/A
# maintainer: HybridOps.Studio

module "vm" {
  source   = "../vm"
  for_each = var.vms

  node_name = var.node_name
  vm_name   = trimspace(try(each.value.vm_name, "")) != "" ? trimspace(try(each.value.vm_name, "")) : each.key
  vm_id     = try(each.value.vm_id, null)

  template_vm_id = var.template_vm_id

  cpu_cores           = var.cpu_cores
  cpu_type            = var.cpu_type
  memory_mb           = var.memory_mb
  disk_size_gb        = var.disk_size_gb
  guest_agent_enabled = var.guest_agent_enabled

  datastore_id = var.datastore_id

  interfaces = (
    try(each.value.interfaces, null) != null
    ? each.value.interfaces
    : var.interfaces
  )

  nameservers = var.nameservers

  ssh_username = var.ssh_username
  ssh_keys     = var.ssh_keys

  os_type = var.os_type
  on_boot = var.on_boot

  tags = concat(var.tags, [each.value.role])

  cloud_init_user_data = (
    try(each.value.cloud_init_user_data, "") != "" ? each.value.cloud_init_user_data :
    (var.cloud_init_user_data != "" ? var.cloud_init_user_data : "")
  )

  cloud_init_network_data = (
    try(each.value.cloud_init_network_data, "") != "" ? each.value.cloud_init_network_data :
    (var.cloud_init_network_data != "" ? var.cloud_init_network_data : "")
  )

  cloud_init_meta_data = (
    try(each.value.cloud_init_meta_data, "") != "" ? each.value.cloud_init_meta_data :
    (var.cloud_init_meta_data != "" ? var.cloud_init_meta_data : "")
  )

  snippets_datastore_id = var.snippets_datastore_id
}
