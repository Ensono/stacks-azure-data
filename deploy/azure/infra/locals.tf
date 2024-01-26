
locals {

  # Create a list of the items for which endpoints need to be created
  # This only applies if the enable_private_networks is enabled
  private_endpoint_list = var.enable_private_networks ? {
    blob = module.adls_default.storage_account_ids[0]
    adls = module.adls_default.storage_account_ids[1]
    kv   = module.kv_default.id
    sql  = module.sql.sql_server_id
    adb  = module.adb.adb_databricks_id
  } : {}

  dns_zone_resource_group_name = var.dns_zone_resource_group_name != "" ? var.dns_zone_resource_group_name : var.vnet_resource_group_name
}
