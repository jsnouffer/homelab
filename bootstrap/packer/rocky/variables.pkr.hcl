variable "proxmox_config" {
  type = object({
    api_url          = string
    username         = string
    target_node      = string
    bridge_interface = string
    storage_pool     = string
  })
}

variable "proxmox_api_password" {
  type    = string
  default = env("PROXMOX_API_PASSWORD")
}

variable "ssh_username" {
  type = string
}

variable "ssh_password" {
  type = string
}

variable "user_password" {
  type    = string
  default = env("ROCKY_USER_PASSWORD")
}

variable "iso_config" {
  type = object({
    iso_file         = string
    iso_url          = string
    iso_checksum     = string
    iso_storage_pool = string
  })
}

variable "boot_disk_config" {
  type = object({
    disk_size       = string
    storage_pool    = string
    type            = string
    scsi_controller = string
  })
}

variable "network_config" {
  type = object({
    bridge = string
    model  = string
  })
}

variable "os" {
  type = string
}

variable "cpu_type" {
  type = string
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}

