# Storage accounts for data lake and config
module "adls_default" {

  source                        = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-adls?ref=v3.0.13"
  resource_namer                = module.default_label_short.id
  resource_group_name           = azurerm_resource_group.default.name
  resource_group_location       = azurerm_resource_group.default.location
  storage_account_details       = var.storage_account_details
  container_access_type         = var.container_access_type
  resource_tags                 = module.default_label_short.tags
  enable_private_network        = var.enable_private_networks
  pe_subnet_id                  = var.enable_private_networks ? lower(tostring(data.azurerm_subnet.pe_subnet[0].id)) : ""
  pe_resource_group_name        = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].resource_group_name) : ""
  pe_resource_group_location    = var.pe_resource_group_location
  dfs_dns_resource_group_name   = local.dns_zone_resource_group_name
  blob_dns_resource_group_name  = local.dns_zone_resource_group_name
  blob_private_dns_zone_name    = var.blob_private_dns_zone_name
  dfs_private_dns_zone_name     = var.dfs_private_dns_zone_name
  public_network_access_enabled = !var.enable_private_networks
  dfs_private_zone_id           = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.dfs_private_zone[0].id) : ""
  blob_private_zone_id          = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.blob_private_zone[0].id) : ""
  azure_object_id               = data.azurerm_client_config.current.object_id
}
