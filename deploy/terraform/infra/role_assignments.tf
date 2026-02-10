resource "azurerm_role_assignment" "kv_role" {
  scope                = module.kv_default.id
  role_definition_name = var.kv_role_adf
  principal_id         = module.adf.adf_managed_identity
}

resource "azurerm_role_assignment" "sql_role" {
  scope                = module.sql.sql_server_id
  role_definition_name = var.sql_role_adf
  principal_id         = module.adf.adf_managed_identity
}

resource "azurerm_role_assignment" "storage_role_config" {
  scope                = module.adls_default.storage_account_ids[1]
  role_definition_name = var.blob_dataconfig_role_adf
  principal_id         = module.adf.adf_managed_identity
}

resource "azurerm_role_assignment" "storage_role" {
  scope                = module.adls_default.storage_account_ids[0]
  role_definition_name = var.adls_datalake_role_adf
  principal_id         = module.adf.adf_managed_identity
}

#Below role assingment is needed to run end to end Test in pipeline
resource "azurerm_role_assignment" "e_2_test_role" {
  scope                = module.adls_default.storage_account_ids[1]
  role_definition_name = var.e_2_test_role
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "adb_role" {
  scope                = module.adb.adb_databricks_id
  role_definition_name = var.adb_role_adf
  principal_id         = module.adf.adf_managed_identity

  depends_on = [data.azurerm_databricks_workspace.verify_adb]
}
