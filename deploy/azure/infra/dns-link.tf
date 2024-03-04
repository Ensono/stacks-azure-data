resource "azurerm_private_dns_zone_virtual_network_link" "privatelink-dns" {
  for_each              = var.link_dns_spoke_network == true && var.enable_private_networks ? toset(var.dns_zone_name) : toset([])
  name                  = data.azurerm_virtual_network.vnet[0].name
  resource_group_name   = var.dns_zone_resource_group_name
  registration_enabled  = false # Auto registration_enabled set to false as we cannot add multiple Private DNS to 1 Vnet
  private_dns_zone_name = each.key
  virtual_network_id    = data.azurerm_virtual_network.vnet[0].id
  depends_on            = [data.azurerm_virtual_network.vnet]
}
