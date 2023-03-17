inputs = {
  api_token_secret = run_cmd("--terragrunt-quiet", "./get-password.sh", "~/.proxmox-api-token")

  proxmox_config = {
    api_url          = "https://pve1man.jsnouff.net/api2/json"
    api_token_id     = "terraform@pam!automation-token"
    target_node      = "pve1"
    bridge_interface = "vmbr0"
    storage_pool     = "local-lvm"
  }

  cluster_name     = "cobra"
  cluster_endpoint = "https://cobra-cp1.jsnouff.net:6443"
  vm_iso           = "local:iso/talos-amd64-v1.3.2.iso"

  network_config = {
    domain_name  = "jsnouff.net"
  }

  cp_config = {
    startup              = "order=2,up=30"
    cores                = 4
    memory               = 16384
    boot_partition_size  = "32G"
    extra_partition_size = "128G"
    ip                   = ["192.168.5.1"]
    mac                  = ["EE:38:05:81:54:65"]
  }

  worker_config = {
    startup              = "order=3"
    cores                = 4
    memory               = 16384
    boot_partition_size  = "32G"
    extra_partition_size = "128G"
    ip                   = ["192.168.5.2", "192.168.5.3"]
    mac                  = ["A6:35:CB:F1:EB:5D", "2A:C4:57:62:08:69"]
  }

}

retryable_errors = [
  "MAC address.*not found"
]
