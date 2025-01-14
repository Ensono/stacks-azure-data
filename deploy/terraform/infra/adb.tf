module "adb" {
  # source                                   = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-adb?ref=v3.0.13"
  adf_private_nsg_subnet_association_id    = var.adf_private_nsg_subnet_association_id
  adf_public_nsg_subnet_association_id     = var.adf_public_nsg_subnet_association_id
  browser_authentication_enabled           = var.browser_authentication_enabled
  create_lb                                = false
  create_nat                               = false
  create_pe_subnet                         = false
  data_platform_log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  databricks_sku                           = var.databricks_sku
  databricksws_diagnostic_setting_name     = var.databricksws_diagnostic_setting_name
  enable_databricksws_diagnostic           = false #var.enable_databricksws_diagnostic
  enable_private_network                   = var.enable_private_networks
  managed_vnet                             = !var.enable_private_networks
  nat_gateway_id                           = var.nat_gateway_id
  nat_gateway_pip_id                       = var.nat_gateway_pip_id
  pe_subnet_id                             = var.enable_private_networks ? data.azurerm_subnet.pe_subnet[0].id : ""
  pe_subnet_name                           = var.pe_subnet_name
  pe_subnet_prefix                         = var.pe_subnet_prefix
  private_dns_zone_id                      = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.adb_private_dns_zone[0].id) : ""
  private_subnet_name                      = var.private_subnet_name
  private_subnet_prefix                    = var.private_subnet_prefix
  public_network_access_enabled            = var.public_network_access_enabled
  public_subnet_name                       = var.public_subnet_name
  public_subnet_prefix                     = var.public_subnet_prefix
  resource_group_location                  = azurerm_resource_group.default.location
  resource_group_name                      = azurerm_resource_group.default.name
  resource_namer                           = module.label_default.id
  resource_tags                            = module.label_default.tags
  source                                   = "../modules/terraform-azurerm-adb"
  virtual_network_id                       = var.enable_private_networks ? tostring(data.azurerm_virtual_network.vnet[0].id) : ""
  vnet_name                                = var.vnet_name
  vnet_resource_group                      = var.vnet_resource_group_name

  depends_on = [azurerm_resource_group.default]
}
