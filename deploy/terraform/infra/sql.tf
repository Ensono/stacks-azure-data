# Storage accounts for data lake and config
module "sql" {
  # source                        = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-sql?ref=v3.0.13"
  source                        = "github.com/ensono/terraform-azurerm-sql"
  resource_namer                = format("%s%s", module.label_default.id, random_string.random_suffix.result)
  resource_group_name           = azurerm_resource_group.default.name
  resource_group_location       = azurerm_resource_group.default.location
  sql_version                   = var.sql_version
  administrator_login           = local.sql_admin_username
  sql_db_names                  = var.sql_db_names
  resource_tags                 = module.label_default.tags
  enable_private_network        = var.enable_private_networks
  pe_subnet_id                  = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].id) : ""
  pe_resource_group_name        = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].resource_group_name) : ""
  pe_resource_group_location    = var.pe_resource_group_location
  dns_resource_group_name       = var.dns_zone_resource_group_name
  public_network_access_enabled = var.sql_public_network_access_enabled
  //As the default SKU in the module is basic, we need to set this to 0 otherwise it defaults to 60 and never gets applied.
  auto_pause_delay_in_minutes = 0
}
