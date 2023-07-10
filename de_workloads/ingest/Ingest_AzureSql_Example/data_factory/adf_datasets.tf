resource "azurerm_data_factory_custom_dataset" "ds_ex_AzureSql_ExampleSource" {
  name            = "NEW_ds_ex_AzureSql_ExampleSource"
  data_factory_id = data.azurerm_data_factory.factory.id
  type            = "AzureSqlTable"
  folder          = "External_Sources"
  linked_service {
    name = azurerm_data_factory_linked_service_azure_sql_database.ls_AzureSql_ExampleSource.name
  }
  type_properties_json = jsonencode({})
  schema_json          = jsonencode({})
}
