module "adb" {
  source                                   = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-adb?ref=v3.0.13"
  resource_namer                           = module.label_default.id
  resource_group_name                      = azurerm_resource_group.default.name
  resource_group_location                  = azurerm_resource_group.default.location
  databricks_sku                           = var.databricks_sku
  resource_tags                            = module.label_default.tags
  enable_databricksws_diagnostic           = false #var.enable_databricksws_diagnostic
  data_platform_log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  databricksws_diagnostic_setting_name     = var.databricksws_diagnostic_setting_name
  enable_private_network                   = var.enable_private_networks
  create_pe_subnet                         = false
  create_subnets                           = true
  vnet_name                                = var.vnet_name
  vnet_resource_group                      = var.vnet_resource_group_name
  virtual_network_id                       = var.enable_private_networks ? tostring(data.azurerm_virtual_network.vnet[0].id) : ""
  public_subnet_name                       = var.public_subnet_name
  private_subnet_name                      = var.private_subnet_name
  pe_subnet_name                           = var.pe_subnet_name
  public_subnet_prefix                     = var.public_subnet_prefix
  private_subnet_prefix                    = var.private_subnet_prefix
  pe_subnet_prefix                         = var.pe_subnet_prefix
  pe_subnet_id                             = var.enable_private_networks ? data.azurerm_subnet.pe_subnet[0].id : ""
  public_network_access_enabled            = var.public_network_access_enabled
  create_nat                               = false
  create_lb                                = false
  managed_vnet                             = !var.enable_private_networks
  browser_authentication_enabled           = var.browser_authentication_enabled
  private_dns_zone_id                      = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.adb_private_dns_zone[0].id) : ""

  depends_on = [azurerm_resource_group.default]
}
