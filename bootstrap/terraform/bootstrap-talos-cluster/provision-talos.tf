resource "talos_machine_secrets" "machine_secrets" {}

resource "talos_machine_configuration_controlplane" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_worker" "machineconfig_worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_client_configuration" "talosconfig" {
  cluster_name    = var.cluster_name
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets
  endpoints       = var.cp_config.ip
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  count = length(var.cp_config.ip)

  talos_config          = talos_client_configuration.talosconfig.talos_config
  machine_configuration = talos_machine_configuration_controlplane.machineconfig_cp.machine_config

  endpoint = data.external.cp_vm_nmap[count.index].result.ip_addr
  node     = data.external.cp_vm_nmap[count.index].result.ip_addr
  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tmpl", {
      cluster_endpoint = var.cluster_endpoint
      dns_name         = "${var.cluster_name}-cp${count.index + 1}.${var.network_config.domain_name}"
      ip_address       = var.cp_config.ip[count.index]
    })
  ]
}

resource "talos_machine_bootstrap" "cp_bootstrap" {
  count      = length(var.cp_config.ip)
  depends_on = [talos_machine_configuration_apply.cp_config_apply]

  talos_config = talos_client_configuration.talosconfig.talos_config
  endpoint     = var.cp_config.ip[count.index]
  node         = var.cp_config.ip[count.index]
}
