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

resource "proxmox_vm_qemu" "vms" {
  provider    = proxmox-telmate
  for_each    = var.node_configs
  name        = each.key
  pool        = proxmox_virtual_environment_pool.cluster_pool.id
  target_node = var.proxmox_config.target_node

  clone      = var.vm_template_name
  full_clone = true

  onboot   = true
  oncreate = true
  agent    = 1
  startup  = each.value.startup
  cores    = each.value.cores
  memory   = each.value.memory
  numa     = true
  hotplug  = "network,disk,usb"

  network {
    model     = "virtio"
    bridge    = var.proxmox_config.bridge_interface
    firewall  = true
    link_down = false
  }

  dynamic "disk" {
    for_each = each.value.disks
    content {
      type    = disk.value["type"]
      storage = var.proxmox_config.storage_pool
      size    = disk.value["size"]
    }
  }

  cloudinit_cdrom_storage = "local-lvm"
  sshkeys                 = var.ssh_key
  ipconfig0               = "ip=${each.value.ip}/16,gw=${var.gateway}"
}
