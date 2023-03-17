resource "proxmox_vm_qemu" "cp_vm" {
  count       = length(var.cp_config.ip)
  name        = "${var.cluster_name}-cp${count.index + 1}"
  target_node = var.proxmox_config.target_node

  iso = var.vm_iso

  onboot   = true
  oncreate = true
  agent    = 0 # if enabled, terraform waits for response from QEMU guest agent
  startup  = var.cp_config.startup
  cores    = var.cp_config.cores
  cpu      = "host" # talos does not support kvm64
  memory   = var.cp_config.memory

  network {
    model     = "virtio"
    bridge    = var.proxmox_config.bridge_interface
    firewall  = true
    link_down = false
    macaddr   = var.cp_config.mac[count.index]
  }

  disk {
    type    = "ide"
    storage = var.proxmox_config.storage_pool
    size    = var.cp_config.boot_partition_size
  }

  disk {
    type    = "ide"
    storage = var.proxmox_config.storage_pool
    size    = var.cp_config.extra_partition_size
  }
}

resource "time_sleep" "wait_for_cp_vm" {
  depends_on      = [proxmox_vm_qemu.cp_vm]
  create_duration = "60s"
}
