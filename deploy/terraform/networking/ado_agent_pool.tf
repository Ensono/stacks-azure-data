
resource "azuredevops_agent_pool" "ado_agent_pool" {
  count = var.enable_private_networks && var.ado_create_agent_pool ? 1 : 0

  name = local.ado_agent_pool_name
}
