terraform {
  required_version = ">= 1.4"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.1.1"
    }
  }
}
