include {
  path = find_in_parent_folders()
}

inputs = {

  cluster_name     = "cobra"
  vm_template_name = "rocky9-template"

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
      memory  = 49152
      ip      = "192.168.5.2"

      disks = [
        {
          type = "scsi"
          size = "150G"
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
      memory  = 49152
      ip      = "192.168.5.3"

      disks = [
        {
          type = "scsi"
          size = "150G"
        },
        {
          type = "scsi"
          size = "500G"
        }
      ]

      usb = []
    },
    "cobra-w3" = {
      startup = "order=3"
      cores   = 6
      memory  = 49152
      ip      = "192.168.5.4"

      disks = [
        {
          type = "scsi"
          size = "150G"
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
