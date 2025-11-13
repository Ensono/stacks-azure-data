data "azurerm_client_config" "current" {}

# Get data about the current subscription
# This is used to determine if there are any tags to denote if the subscription
# is a prod or nonprod sub or it should be overridden
data "azurerm_subscription" "current" {}

# Obtain some environment variables that can be used in the terraform configuration
# This is primarily used to get the name of the environment being deployed
data "external" "env" {
  program = ["${path.module}/scripts/env.sh"]
}

# Get the UUID of the Azure DevOps project, if it is being updated
data "azuredevops_project" "ado" {
  count = var.enable_private_networks && var.ado_create_variable_group ? 1 : 0
  name  = var.ado_project_id
}
