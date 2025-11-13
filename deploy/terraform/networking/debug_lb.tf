
resource "azurerm_lb" "debug" {
  count               = var.enable_private_networks == true && var.debug_enabled == true ? 1 : 0
  name                = "${module.label_default.id}-debug"
  location            = var.resource_group_location
  resource_group_name = module.networking[0].vnets[local.hub_network_name].vnet_resource_group_name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.debug_public_ip[0].id
  }
}
