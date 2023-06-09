inputs = {
  api_password = run_cmd("--terragrunt-quiet", "./get-password.sh", "~/.proxmox-api-password")
  ssh_key      = run_cmd("--terragrunt-quiet", "./get-password.sh", "~/.ssh/id_rsa.pub")

  proxmox_config = {
    api_url          = "https://pve1man.jsnouff.net"
    api_user         = "root@pam"
    target_node      = "pve1"
    bridge_interface = "vmbr0"
    storage_pool     = "local-lvm"
  }

  cluster_name     = "cobra"
  vm_template_name = "rocky9-template"
  gateway          = "192.168.1.1"

  node_configs = {
    "cobra-cp" = {
      startup = "order=2,up=30"
      cores   = 1
      memory  = 8192
      ip      = "192.168.5.1"

      disks = [
        {
          type = "scsi"
          size = "32G"
        },
        {
          type = "scsi"
          size = "128G"
        }
      ]

      usb = []
    },
    "cobra-w1" = {
      startup = "order=3"
      cores   = 6
      memory  = 32768
      ip      = "192.168.5.2"

      disks = [
        {
          type = "scsi"
          size = "75G"
        },
        {
          type = "scsi"
          size = "500G"
        }
      ]

      usb = []
    },
    "cobra-w2" = {
      startup = "order=3"
      cores   = 6
      memory  = 32768
      ip      = "192.168.5.3"

      disks = [
        {
          type = "scsi"
          size = "75G"
        },
        {
          type = "scsi"
          size = "500G"
        }
      ]

      usb = []
    }
  }

}
