packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
# see https://github.com/dustinrue/proxmox-packer/blob/main/rocky9/packer.json
source "proxmox-iso" "rocky9-iso" {
  template_name        = "rocky9-template"
  template_description = "rocky linux 9, generated on ${timestamp()}"

  iso_file = var.iso_config.iso_file
  # iso_url          = var.iso_config.iso_url
  # iso_checksum     = var.iso_config.iso_checksum
  # iso_storage_pool = var.iso_config.iso_storage_pool
  # iso_download_pve = true
  unmount_iso = true

  username                 = var.proxmox_config.username
  password                 = var.proxmox_api_password
  proxmox_url              = var.proxmox_config.api_url
  node                     = var.proxmox_config.target_node
  insecure_skip_tls_verify = true

  http_directory = "http_directory"
  task_timeout   = "15m"

  os       = var.os
  cpu_type = var.cpu_type
  cores    = var.cores
  memory   = var.memory

  boot_command = [
    "<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/inst.ks<enter><wait>"
  ]

  boot_wait = "10s"

  network_adapters {
    bridge = var.network_config.bridge
    model  = var.network_config.model
  }

  disks {
    disk_size    = var.boot_disk_config.disk_size
    storage_pool = var.boot_disk_config.storage_pool
    type         = var.boot_disk_config.type
  }

  scsi_controller = var.boot_disk_config.scsi_controller

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "15m"
}

build {
  sources = ["source.proxmox-iso.rocky9-iso"]
  provisioner "shell" {
    inline = [
      "yum install -y epel-release", # extra packages repo
      "yum install -y bind-utils net-tools htop cifs-utils nfs-utils",
      "yum install -y cloud-init qemu-guest-agent cloud-utils-growpart gdisk",
      "systemctl enable qemu-guest-agent",
      "shred -u /etc/ssh/*_key /etc/ssh/*_key.pub",
      "rm -f /root/*ks",
      "passwd -d root",
      "passwd -l root",
      "echo 'root:${var.user_password}' | chpasswd",
      "rm -f /etc/ssh/ssh_config.d/allow-root-ssh.conf",
      "rm -f /var/run/utmp",
      ">/var/log/lastlog",
      ">/var/log/wtmp",
      ">/var/log/btmp",
      "rm -rf /tmp/* /var/tmp/*",
      "unset HISTFILE; rm -rf /home/*/.*history /root/.*history"
    ]
  }
}

