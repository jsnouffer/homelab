inputs = {
  api_password = run_cmd("--terragrunt-quiet", "./get-password.sh", "~/.proxmox-api-password")
  ssh_key      = run_cmd("--terragrunt-quiet", "./get-password.sh", "~/.ssh/id_rsa.pub")

  proxmox_config = {
    api_url          = "https://pve1man.jsnouff.net"
    api_user         = "terraform@pam"
    target_node      = "pve1"
    bridge_interface = "vmbr0"
    storage_pool     = "local-lvm"
  }

  cluster_name     = "cobra"
  vm_template_name = "rocky9-template"
  gateway          = "192.168.1.1"

  cp_config = {
    startup              = "order=2,up=30"
    cores                = 2
    memory               = 12288
    boot_partition_size  = "32G"
    extra_partition_size = "128G"
    ip                   = ["192.168.5.1"]
  }

  worker_config = {
    startup              = "order=3"
    cores                = 6
    memory               = 32768
    boot_partition_size  = "32G"
    extra_partition_size = "128G"
    ip                   = ["192.168.5.2", "192.168.5.3"]
  }

}
