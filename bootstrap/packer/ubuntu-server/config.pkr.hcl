packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.7"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
source "proxmox-iso" "ubuntu-server-iso" {
  template_name        = "ubuntu-server-template"
  template_description = "ubuntu server 22.04.3, generated on ${timestamp()}"

  iso_file = var.iso_config.iso_file
  unmount_iso = true

  username                 = var.proxmox_config.username
  password                 = var.proxmox_api_password
  proxmox_url              = var.proxmox_config.api_url
  node                     = var.proxmox_config.target_node
  insecure_skip_tls_verify = true

  http_directory = ""
  task_timeout   = "15m"

  os       = var.os
  cpu_type = var.cpu_type
  cores    = var.cores
  memory   = var.memory

  additional_iso_files {
    unmount          = true
    iso_storage_pool = "local"
    cd_content = {
      "meta-data" = file("./data/meta-data")
      "user-data" = templatefile("./data/user-data.tpl", {
        username    = var.ssh_username,
        password    = var.ssh_password_encrypted
      }),
    }
    cd_label = "cidata"
  }

  boot_command = [
    "<wait3s>c<wait3s>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud\"",
    "<enter><wait3s>",
    "initrd /casper/initrd",
    "<enter><wait3s>",
    "boot",
    "<enter>"
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
  ssh_timeout  = "20m"
}

build {
  sources = ["source.proxmox-iso.ubuntu-server-iso"]
  provisioner "shell" {
    inline = [
      "sudo apt-get install -y net-tools htop cifs-utils libnfs-utils cloud-init gdisk python3-pip",
      "sudo python3 -m pip install oauthlib==3.2.2", # needed for Ansible kubernetes module
      "sudo shred -u /etc/ssh/*_key /etc/ssh/*_key.pub",
      "sudo passwd -d root",
      "sudo passwd -l root",
      "sudo echo 'root:${var.user_password}' | sudo chpasswd",
      "echo '${var.ssh_username}:${var.user_password}' | sudo chpasswd",
      "sudo dpkg-reconfigure openssh-server",
      "sudo apt-get purge -y cloud-init; sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/", # purge bootstrap cloud-init configuration
      "sudo apt-get install -y cloud-init", # re-enable cloud-init for proxmox cloud-init injection
      "sudo rm -f /etc/ssh/ssh_config.d/allow-root-ssh.conf",
      "sudo rm -f /var/run/utmp",
      "sudo rm -f /var/log/lastlog",
      "sudo rm -f /var/log/wtmp",
      "sudo rm -f /var/log/btmp",
      "sudo rm -rf /tmp/* /var/tmp/*",
      "sudo sh -c unset HISTFILE; sudo rm -rf /home/*/.*history /root/.*history; unset HISTFILE"
    ]
  }
}

