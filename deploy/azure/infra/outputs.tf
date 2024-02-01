output "resource_group_name" {
  description = "Name of the resource group that things have been deployed into"
  value       = azurerm_resource_group.default.name
  depends_on  = [azurerm_resource_group.default]
}
