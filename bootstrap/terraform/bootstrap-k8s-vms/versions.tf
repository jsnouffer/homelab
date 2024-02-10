terraform {
  required_version = ">= 1.4"

  required_providers {
    proxmox-telmate = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }

    proxmox-bpg = {
      source  = "bpg/proxmox"
      version = "0.14.1"
    }

    pihole = {
      source = "ryanwholey/pihole"
      version = "0.2.0"
    }
  }
}
