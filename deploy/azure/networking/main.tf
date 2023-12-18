locals {
  # Get the hub network name which will be used later to deploy the vmss into it
  hub_network_name = [for network in local.network_details : network.name if network.is_hub == true][0]
}

# Naming convention
module "default_label" {
  source          = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace       = format("%s-%s", var.name_company, var.name_project)
  stage           = var.stage
  name            = "${lookup(local.location_name_map, var.resource_group_location)}-${var.name_component}"
  attributes      = var.attributes
  delimiter       = "-"
  id_length_limit = 60
  tags            = var.tags
}

module "networking" {
  source                  = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-hub-spoke?ref=fix/deployment"
  enable_private_networks = var.enable_private_networks ## NOTE setting this value to false will cause no resources to be created !!
  network_details         = local.network_details
  resource_group_location = var.resource_group_location
  create_hub_fw           = var.create_hub_fw
  create_fw_public_ip     = var.create_fw_public_ip
  dns_zone_name           = ["${module.default_label.id}.com"]
  merge_dns_zones         = true
  link_dns_network        = var.link_dns_network
}

module "vmss" {
  count                        = var.enable_private_networks ? 1 : 0
  source                       = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-vmss?ref=fix/deployment"
  vmss_name                    = module.default_label.id
  vmss_resource_group_name     = length(module.networking) > 0 ? module.networking.vnets[module.networking.hub_net_name].vnet_resource_group_name : ""
  vmss_resource_group_location = var.resource_group_location
  vnet_name                    = module.networking.hub_net_name
  vnet_resource_group          = module.networking.vnets[module.networking.hub_net_name].vnet_resource_group_name
  subnet_name                  = var.vmss_subnet_name
  vmss_instances               = var.vmss_instances
  vmss_admin_username          = var.vmss_admin_username
  vmss_disable_password_auth   = var.vmss_disable_password_auth
  vmss_sku = "Standard_DSv2"
  depends_on                   = [module.networking]
}
