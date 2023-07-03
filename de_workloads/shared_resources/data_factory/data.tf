data "azurerm_data_factory" "factory" {
  name                = var.data_factory
  resource_group_name = var.data_factory_resource_group_name
}

# TODO: See if we can just get the key vault name, rather than having to extract it from the URI
data "azurerm_key_vault" "key_vault" {
  name                = regex("\\/\\/(.*?)\\.", var.key_vault_uri)[0]
  resource_group_name = var.key_vault_resource_group_name
}
