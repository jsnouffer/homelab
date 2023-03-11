provider "proxmox" {
  pm_api_url          = var.proxmox_config.api_url
  pm_api_token_id     = var.proxmox_config.api_token_id
  pm_api_token_secret = var.api_token_secret
  pm_tls_insecure     = true
}

provider "talos" {}