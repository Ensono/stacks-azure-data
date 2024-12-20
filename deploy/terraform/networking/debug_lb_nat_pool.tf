resource "azurerm_lb_nat_pool" "debug" {
  count                          = var.enable_private_networks == true && var.debug_enabled == true ? 1 : 0
  resource_group_name            = module.networking[0].vnets[local.hub_network_name].vnet_resource_group_name
  loadbalancer_id                = azurerm_lb.debug[0].id
  name                           = "SSH"
  protocol                       = "Tcp"
  frontend_port_start            = 2222
  frontend_port_end              = 2232
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_port                   = 22
}
