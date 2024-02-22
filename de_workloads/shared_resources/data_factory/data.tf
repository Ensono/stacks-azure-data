data "azurerm_data_factory" "factory" {
  name                = var.data_factory
  resource_group_name = var.data_factory_resource_group_name
}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}
