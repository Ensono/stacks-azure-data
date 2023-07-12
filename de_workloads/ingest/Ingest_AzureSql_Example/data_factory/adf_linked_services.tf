resource "azurerm_data_factory_linked_custom_service" "ls_AzureSql_ExampleSource" {
  name            = "ls_AzureSql_ExampleSource"
  data_factory_id = data.azurerm_data_factory.factory.id
  integration_runtime {
    name = var.integration_runtime_name
  }
  type                 = var.linked_service_type
  description          = "Azure SQL example linked service."
  type_properties_json = <<JSON
{
  "connectionString": "${var.azuresql_examplesource_connectionstring}",
  "password": {
      "type": "AzureKeyVaultSecret",
      "store": {
          "referenceName": "${var.key_vault_linked_service_name}",
          "type": "LinkedServiceReference"
      },
      "secretName": "${var.key_vault_secret_name}"
  }
}
JSON
}
