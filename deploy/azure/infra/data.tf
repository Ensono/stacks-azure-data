data "azurerm_client_config" "current" {}

data "azurerm_subnet" "pe_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}
/*
data "azurerm_private_dns_zone" "private_dns" {
  name                = var.dns_zone_namede
  resource_group_name = var.dns_zone_resource_group

}

*/

data "azurerm_virtual_network" "dev" {
  name                = var.dev_network_spoke
  resource_group_name = var.dev_vnet_resource_group_name
}

data "azurerm_virtual_network" "prod" {
  name                = var.prod_network_spoke
  resource_group_name = var.prod_vnet_resource_group_name
}
