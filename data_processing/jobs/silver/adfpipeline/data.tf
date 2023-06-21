data "azurerm_data_factory" "example" {
  name                = var.data_factory
  resource_group_name = var.data_factory_resource_group_name
}

output "data_factory_name" {
  value = data.azurerm_data_factory.example.name
}