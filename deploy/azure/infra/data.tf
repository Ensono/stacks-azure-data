data "azurerm_client_config" "current" {}

data "azurerm_subnet" "pe_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

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
  name                = var.adb_private_zone
  resource_group_name = var.dns_zone_resource_group
}

# Get information about all the private endpoint connections on the storage account
data "azapi_resource" "private_endpoint_connections" {
  type = "Microsoft.Storage/storageAccounts@2022-09-01"
}
