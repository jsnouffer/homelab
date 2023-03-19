inputs = {
  api_password = run_cmd("--terragrunt-quiet", "./get-password.sh", "~/.proxmox-api-password")

  proxmox_config = {
    api_url          = "https://pve1man.jsnouff.net"
    api_user         = "terraform@pam"
    target_node      = "pve1"
    bridge_interface = "vmbr0"
    storage_pool     = "local-lvm"
  }

  cluster_name     = "cobra"
  vm_template_name = "rocky9-template"

  cp_config = {
    startup              = "order=2,up=30"
    cores                = 4
    memory               = 16384
    extra_partition_size = "128G"
    ip                   = ["192.168.5.1"]
    mac                  = ["EE:38:05:81:54:65"]
  }

  worker_config = {
    startup              = "order=3"
    cores                = 4
    memory               = 16384
    extra_partition_size = "128G"
    ip                   = ["192.168.5.2", "192.168.5.3"]
    mac                  = ["A6:35:CB:F1:EB:5D", "2A:C4:57:62:08:69"]
  }

}
