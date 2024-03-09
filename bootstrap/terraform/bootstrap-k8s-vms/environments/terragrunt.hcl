terraform {
  source = "${get_parent_terragrunt_dir()}/../"
}

inputs = {
  proxmox_password = run_cmd("--terragrunt-quiet", "${get_parent_terragrunt_dir()}/get-password.sh", "~/.proxmox-api-password")
  pihole_password  = run_cmd("--terragrunt-quiet", "${get_parent_terragrunt_dir()}/get-password.sh", "~/.pihole-password")
  ssh_key          = run_cmd("--terragrunt-quiet", "${get_parent_terragrunt_dir()}/get-password.sh", "~/.ssh/id_rsa.pub")

  gateway = "192.168.1.1"

  proxmox_config = {
    api_url          = "https://pve1.jsnouff.net"
    api_user         = "root@pam"
    target_node      = "pve1"
    bridge_interface = "vmbr0"
    storage_pool     = "local-lvm"
  }

  pihole_primary   = "https://pihole.jsnouff.net"
  pihole_secondary = "https://pihole2.jsnouff.net"

  pihole_records_base_domain = "jsnouff.net"
}