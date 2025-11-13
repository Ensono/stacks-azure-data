resource "azapi_resource_action" "test" {
  count       = var.ir_enable_interactive_authoring && var.managed_virtual_network_enabled ? 1 : 0
  type        = "Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01"
  resource_id = azurerm_data_factory_integration_runtime_azure.example[0].id
  action      = "enableInteractiveQuery"
  body = {
    autoTerminationMinutes = 10
  }

  depends_on = [azurerm_data_factory_integration_runtime_azure.example]
}
