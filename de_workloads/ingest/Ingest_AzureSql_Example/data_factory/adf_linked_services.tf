resource "azurerm_data_factory_linked_service_azure_sql_database" "ls_AzureSql_ExampleSource" {
  name                     = "NEW_ls_AzureSql_ExampleSource"
  data_factory_id          = data.azurerm_data_factory.factory.id
  integration_runtime_name = var.integration_runtime_name
  description              = "Azure SQL example linked service."
  connection_string        = var.azuresql_examplesource_connectionstring
  key_vault_password {
    linked_service_name = var.key_vault_linked_service_name
    secret_name         = "sql-password"
  }
}
