
# Create the agent pool at the Organisation level
resource "azuredevops_agent_pool" "ado_agent_pool" {
  count = var.enable_private_networks && var.ado_create_agent_pool ? 1 : 0

  name = local.ado_agent_pool_name
}

# Add an agent queue to the project which uses the agent pool above
resource "azuredevops_agent_queue" "ago_agent_queue" {
  count = var.enable_private_networks && var.ado_create_agent_pool ? 1 : 0

  project_id    = data.azuredevops_project.ado[0].id
  agent_pool_id = azuredevops_agent_pool.ado_agent_pool[0].id
}

# Grant access to all the pipelines in the project
resource "azuredevops_resource_authorization" "ado_agent_perms" {
  count = var.enable_private_networks && var.ado_create_agent_pool ? 1 : 0

  project_id  = data.azuredevops_project.ado[0].id
  resource_id = azuredevops_agent_queue.ago_agent_queue[0].id

  type       = "queue"
  authorized = true
}
