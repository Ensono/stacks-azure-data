resource "azurerm_private_dns_zone_virtual_network_link" "dev-privatelink-dns" {
  for_each              = var.link_dns_dev_spoke_network == true ? toset(var.dns_zone_name) : toset([])
  name                  = data.azurerm_virtual_network.dev.name
  resource_group_name   = var.dns_zone_resource_group
  registration_enabled  = false # Auto registration_enabled set to false as we cannot add multiple Private DNS to 1 Vnet
  private_dns_zone_name = each.key
  virtual_network_id    = data.azurerm_virtual_network.dev.id
  depends_on            = [data.azurerm_virtual_network.dev]
}

resource "azurerm_private_dns_zone_virtual_network_link" "prod-privatelink-dns" {
  for_each              = var.link_dns_prod_spoke_network == true ? toset(var.dns_zone_name) : toset([])
  name                  = data.azurerm_virtual_network.prod.name
  resource_group_name   = var.dns_zone_resource_group
  registration_enabled  = false # Auto registration_enabled set to false as we cannot add multiple Private DNS to 1 Vnet
  private_dns_zone_name = each.key
  virtual_network_id    = data.azurerm_virtual_network.prod.id
  depends_on            = [data.azurerm_virtual_network.dev]
}
