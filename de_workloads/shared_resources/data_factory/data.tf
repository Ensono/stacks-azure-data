data "azurerm_data_factory" "factory" {
  name                = var.data_factory
  resource_group_name = var.data_factory_resource_group_name
}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

data "terraform_remote_state" "data_infra" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tf_state_resource_group_name
    storage_account_name = var.tf_state_storage_account_name
    container_name       = var.tf_state_container_name
    key                  = var.tf_state_container_key_name
  }
}
