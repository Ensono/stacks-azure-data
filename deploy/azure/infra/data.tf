data "azurerm_storage_account" "linked_adls" {
  name                = module.adls_default.storage_account_names[0]
  resource_group_name = azurerm_resource_group.default.name
}


data "azurerm_storage_account" "linked_blob_config" {
  name                = module.adls_default.storage_account_names[1]
  resource_group_name = azurerm_resource_group.default.name
}


data "azurerm_client_config" "current" {}
