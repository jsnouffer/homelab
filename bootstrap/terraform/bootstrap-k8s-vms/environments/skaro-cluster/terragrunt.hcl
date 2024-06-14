include {
  path = find_in_parent_folders()
}

inputs = {

  cluster_name     = "skaro"
  vm_template_name = "ubuntu-server-template"

  node_configs = {
    "dalek-caan" = {
      startup = ""
      cores   = 8
      memory  = 32768
      ip      = "192.168.5.16"

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
