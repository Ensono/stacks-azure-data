resource "azurerm_data_factory_integration_runtime_azure" "example" {
  count                   = var.managed_virtual_network_enabled ? 1 : 0
  name                    = var.adf_managed-vnet-runtime_name
  data_factory_id         = azurerm_data_factory.example[0].id
  location                = var.resource_group_location
  virtual_network_enabled = var.runtime_virtual_network_enabled
}
