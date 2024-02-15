include {
  path = find_in_parent_folders()
}

inputs = {

  cluster_name     = "skaro"
  vm_template_name = "ubuntu-server-template"

  node_configs = {
    "dalek-sec" = {
      startup = ""
      cores   = 4
      memory  = 24576
      ip      = "192.168.5.11"

      disks = [
        {
          type = "scsi"
          size = "150G"
        },
        {
          type = "scsi"
          size = "200G"
        }
      ]

      usb = []
    },
    "dalek-caan" = {
      startup = ""
      cores   = 4
      memory  = 24576
      ip      = "192.168.5.12"

      disks = [
        {
          type = "scsi"
          size = "150G"
        },
        {
          type = "scsi"
          size = "200G"
        }
      ]

      usb = []
    }
  }

}
