packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "k3os-iso" {
  template_name        = "k3os"
  template_description = "k3os v0.22.2-k3s2r0, generated on ${timestamp()}"
  iso_url              = "https://github.com/rancher/k3os/releases/download/v0.22.2-k3s2r0/k3os-amd64.iso"
  iso_checksum         = "eae289cf81bdd68f23154b42c751ca571604625a1cfdbc239141c78287dd587c"
  iso_storage_pool     = "local"

  username    = var.proxmox_config.username
  password    = var.proxmox_api_password
  proxmox_url = var.proxmox_config.api_url
  node        = var.proxmox_config.target_node



  # boot_command = ["<up><tab> ip=dhcp inst.cmdline inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"]
  # boot_wait    = "10s"

  disks {
    disk_size    = "5G"
    storage_pool = "local-lvm"
    type         = "scsi"
  }
  efi_config {
    efi_storage_pool  = "local-lvm"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }
  # http_directory           = "config"
  insecure_skip_tls_verify = true
  # iso_file                 = "local:iso/Fedora-Server-dvd-x86_64-37-1.7.iso"
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  ssh_password = "packer"
  ssh_timeout  = "15m"
  ssh_username = "root"
  # template_description = "Fedora 29-1.2, generated on ${timestamp()}"
  # template_name        = "fedora-29"
  unmount_iso = true
}

build {
  sources = ["source.proxmox-iso.k3os-iso"]
}
