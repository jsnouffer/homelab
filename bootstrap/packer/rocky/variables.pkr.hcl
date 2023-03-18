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

variable "iso_config" {
  type = object({
    iso_file         = string
    iso_url          = string
    iso_checksum     = string
    iso_storage_pool = string
  })
}
