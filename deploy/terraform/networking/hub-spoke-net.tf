module "networking" {
  count  = var.enable_private_networks ? 1 : 0
  source = "github.com/ensono/terraform-azurerm-hub-spoke-network"
  ## NOTE setting this value to false will cause no resources to be created !!
  network_details         = local.network_details
  resource_group_location = var.resource_group_location
  create_hub_fw           = var.create_hub_fw
  create_fw_public_ip     = var.create_fw_public_ip
  create_private_dns_zone = var.create_private_dns_zone
  dns_zone_name           = var.dns_zone_name
  link_dns_network        = var.link_dns_network
  label                   = module.label_default.id
  debug_enabled           = var.debug_enabled
}
