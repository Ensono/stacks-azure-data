data "azurerm_client_config" "current" {}

data "terraform_remote_state" "core" {
  backend = "azurerm"

  config = {
    key                  = "${var.tfstate_key}:${var.core_environment}"
    storage_account_name = var.tfstate_storage_account
    container_name       = var.tfstate_container_name
    resource_group_name  = var.tfstate_resource_group_name
  }
}

data "azurerm_application_insights" "example" {
  name                = data.terraform_remote_state.core.outputs.app_insights_name
  resource_group_name = data.terraform_remote_state.core.outputs.resource_group_name
}
