include {
  path = find_in_parent_folders()
}

inputs = {

  cluster_name     = "infrastructure"
  vm_template_name = "ubuntu-server-template"

  node_configs = {
    "mandos" = {
      startup = ""
      cores   = 2
      memory  = 4096
      ip      = "192.168.3.1"

      disks = [
        {
          type = "scsi"
          size = "150G"
        }
      ]

      usb = []
    }
  }

}
