variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "pihole_password" {
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

variable "node_configs" {
  type = map(object({
    startup              = string
    cores                = number
    memory               = number
    ip                   = string
    disks = list(object({
      type = string
      size = string
    }))
    usb = list(string)
  }))
}

variable "pihole_primary" {
  type = string
}

variable "pihole_secondary" {
  type = string
}

variable "pihole_records_base_domain" {
  type = string
}