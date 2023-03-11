variable "api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_config" {
  type = object({
    api_url          = string
    api_token_id     = string
    target_node      = string
    bridge_interface = string
    storage_pool     = string
  })
}

variable "vm_iso" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "network_config" {
  type = object({
    dhcp_ip_cidr = string
    domain_name  = string
  })
}

variable "cp_config" {
  type = object({
    startup              = string
    cores                = number
    memory               = number
    boot_partition_size  = string
    extra_partition_size = string
    ip                   = list(string)
  })
}

variable "worker_config" {
  type = object({
    startup              = string
    cores                = number
    memory               = number
    boot_partition_size  = string
    extra_partition_size = string
    ip                   = list(string)
  })
}
