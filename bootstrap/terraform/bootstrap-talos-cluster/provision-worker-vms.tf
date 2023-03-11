resource "proxmox_vm_qemu" "worker_vm" {
  count       = length(var.worker_config.ip)
  name        = "${var.cluster_name}-w${count.index + 1}"
  target_node = var.proxmox_config.target_node

  iso = var.vm_iso

  onboot   = true
  oncreate = true
  agent    = 0 # if enabled, terraform waits for response from QEMU guest agent
  startup  = var.worker_config.startup
  cores    = var.worker_config.cores
  cpu      = "host" # talos does not support kvm64
  memory   = var.worker_config.memory

  network {
    model     = "virtio"
    bridge    = var.proxmox_config.bridge_interface
    firewall  = true
    link_down = false
  }

  disk {
    type    = "scsi"
    storage = var.proxmox_config.storage_pool
    size    = var.worker_config.boot_partition_size
  }

  disk {
    type    = "scsi"
    storage = var.proxmox_config.storage_pool
    size    = var.worker_config.extra_partition_size
  }
}

resource "time_sleep" "wait_for_worker_vm" {
  depends_on      = [proxmox_vm_qemu.worker_vm]
  create_duration = "15s"
}

data "external" "worker_vm_nmap" {
  count = length(var.worker_config.ip)

  program = ["./get-ip-addr-from-mac-addr.sh", var.network_config.dhcp_ip_cidr, proxmox_vm_qemu.worker_vm[count.index].network[0].macaddr]
  depends_on = [time_sleep.wait_for_worker_vm]
}
