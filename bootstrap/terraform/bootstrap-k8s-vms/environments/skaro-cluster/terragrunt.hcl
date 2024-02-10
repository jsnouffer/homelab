include {
  path = find_in_parent_folders()
}

inputs = {

  cluster_name     = "skaro"
  vm_template_name = "ubuntu-server-template"

  node_configs = {
    "dalek-sec" = {
      startup = ""
      cores   = 2
      memory  = 16384
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
    }
  }

}
