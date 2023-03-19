provider "proxmox-telmate" {
  pm_api_url      = "${var.proxmox_config.api_url}/api2/json"
  pm_user         = var.proxmox_config.api_user
  pm_password     = var.api_password
  pm_tls_insecure = true
}

provider "proxmox-bpg" {
  virtual_environment {
    endpoint = var.proxmox_config.api_url
    username = var.proxmox_config.api_user
    password = var.api_password
    insecure = true
  }
}

resource "proxmox_virtual_environment_pool" "cluster_pool" {
  provider = proxmox-bpg
  pool_id  = var.cluster_name
  comment  = "Managed by Terraform"
}

resource "proxmox_vm_qemu" "cp_vms" {
  provider    = proxmox-telmate
  count       = length(var.cp_config.ip)
  name        = "${var.cluster_name}-cp${count.index + 1}"
  pool        = proxmox_virtual_environment_pool.cluster_pool.id
  target_node = var.proxmox_config.target_node

  clone      = var.vm_template_name
  full_clone = true

  onboot   = true
  oncreate = true
  agent    = 1
  startup  = var.cp_config.startup
  cores    = var.cp_config.cores
  memory   = var.cp_config.memory

  network {
    model     = "virtio"
    bridge    = var.proxmox_config.bridge_interface
    firewall  = true
    link_down = false
  }

  disk {
    type    = "scsi"
    storage = var.proxmox_config.storage_pool
    size    = var.cp_config.extra_partition_size
  }

  cloudinit_cdrom_storage = "local-lvm"
  sshkeys                 = var.ssh_key
  ipconfig0               = "ip=${var.cp_config.ip[count.index]}/16,gw=${var.gateway}"
}

resource "proxmox_vm_qemu" "worker_vms" {
  provider    = proxmox-telmate
  count       = length(var.worker_config.ip)
  name        = "${var.cluster_name}-w${count.index + 1}"
  pool        = proxmox_virtual_environment_pool.cluster_pool.id
  target_node = var.proxmox_config.target_node

  clone      = var.vm_template_name
  full_clone = true

  onboot   = true
  oncreate = true
  agent    = 1
  startup  = var.worker_config.startup
  cores    = var.worker_config.cores
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
    size    = var.worker_config.extra_partition_size
  }

  cloudinit_cdrom_storage = "local-lvm"
  sshkeys                 = var.ssh_key
  ipconfig0               = "ip=${var.worker_config.ip[count.index]}/16,gw=${var.gateway}"
}
