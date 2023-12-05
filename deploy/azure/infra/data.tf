data "azurerm_client_config" "current" {}

data "azurerm_subnet" "pe_subnet" {
  count                = var.enable_private_networks ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_private_dns_zone" "private_dns" {
  count               = var.enable_private_networks ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group
}
