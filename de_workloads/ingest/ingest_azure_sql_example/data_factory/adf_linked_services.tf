resource "azurerm_data_factory_linked_custom_service" "ls_azure_sql_example" {
  name            = "ls_azure_sql_example"
  data_factory_id = data.azurerm_data_factory.factory.id
  integration_runtime {
    name = var.integration_runtime_name
  }
  type                 = "AzureSqlDatabase"
  description          = "AZURE_SQL linked service."
  type_properties_json = <<JSON
{
  "connectionString": "${var.linked_service_connectionstring}",
  "password": {
      "type": "AzureKeyVaultSecret",
      "store": {
          "referenceName": "${var.key_vault_linked_service_name}",
          "type": "LinkedServiceReference"
      },
      "secretName": "sql-password"
  }
}
JSON
}
