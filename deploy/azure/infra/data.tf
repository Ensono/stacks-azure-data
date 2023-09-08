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

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

data "azurerm_private_dns_zone" "dfs_private_zone" {
  name                = var.dfs_private_zone
  resource_group_name = var.dns_zone_resource_group
}

data "azurerm_private_dns_zone" "blob_private_zone" {
  name                = var.blob_private_zone
  resource_group_name = var.dns_zone_resource_group
}

data "azurerm_private_dns_zone" "kv_private_dns_zone" {
  name                = var.kv_private_zone
  resource_group_name = var.dns_zone_resource_group
}

data "azurerm_private_dns_zone" "sql_private_dns_zone" {
  name                = var.sql_private_zone
  resource_group_name = var.dns_zone_resource_group
}

data "azurerm_private_dns_zone" "adb_private_dns_zone" {
  # count               = var.enable_private_network ? 1 : 0
  name                = var.adb_private_zone
  resource_group_name = var.dns_zone_resource_group
}
