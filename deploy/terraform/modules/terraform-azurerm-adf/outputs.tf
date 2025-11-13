output "adf_factory_id" {
  value = azurerm_data_factory.example.0.id
}

output "adf_account_name" {
  description = "Azure Data Factory Name"
  value       = azurerm_data_factory.example.0.name
}

output "adf_managed_identity" {
  description = "Azure Data Factory Name"
  value       = azurerm_data_factory.example.0.identity[0].principal_id
}

output "adf_integration_runtime_name" {
  description = "The Integration Runtime using VNET"
  value       = var.managed_virtual_network_enabled ? azurerm_data_factory_integration_runtime_azure.example[0].name : "AutoResolveIntegrationRuntime"
}
