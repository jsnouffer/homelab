variable "api_password" {
  type      = string
  sensitive = true
}

variable "ssh_key" {
  type      = string
  sensitive = true
}

variable "proxmox_config" {
  type = object({
    api_url          = string
    api_user         = string
    target_node      = string
    bridge_interface = string
    storage_pool     = string
  })
}

variable "vm_template_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "gateway" {
  type = string
}

variable "cp_config" {
  type = object({
    startup              = string
    cores                = number
    memory               = number
    extra_partition_size = string
    ip                   = list(string)
  })
}

variable "worker_config" {
  type = object({
    startup              = string
    cores                = number
    memory               = number
    extra_partition_size = string
    ip                   = list(string)
  })
}
