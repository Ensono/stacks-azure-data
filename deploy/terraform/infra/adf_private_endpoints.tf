resource "azurerm_data_factory_managed_private_endpoint" "adls_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_dfs
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.adls_default.storage_account_ids[1]
  subresource_name   = "dfs"

  depends_on = [time_sleep.wait_for_resources]
}

resource "azurerm_data_factory_managed_private_endpoint" "blob_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_blob
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.adls_default.storage_account_ids[0]
  subresource_name   = "blob"

  depends_on = [time_sleep.wait_for_resources]
}

resource "azurerm_data_factory_managed_private_endpoint" "db_auth_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = "${var.name_pe_db}_auth"
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.adb.adb_databricks_id
  subresource_name   = "browser_authentication"

  depends_on = [time_sleep.wait_for_resources, time_sleep.wait_after_databricks]
}

resource "azurerm_data_factory_managed_private_endpoint" "db_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_db
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.adb.adb_databricks_id
  subresource_name   = "databricks_ui_api"

  depends_on = [time_sleep.wait_for_resources, time_sleep.wait_after_databricks]
}

resource "azurerm_data_factory_managed_private_endpoint" "kv_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_kv
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.kv_default.id
  subresource_name   = "vault"

  depends_on = [time_sleep.wait_for_resources, time_sleep.wait_after_databricks]
}

resource "azurerm_data_factory_managed_private_endpoint" "sql_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_sql
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.sql.sql_server_id
  subresource_name   = "sqlServer"

  depends_on = [time_sleep.wait_for_resources, time_sleep.wait_after_databricks]
}
