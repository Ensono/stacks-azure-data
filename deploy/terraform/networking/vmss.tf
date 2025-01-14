
module "terraform-azurerm-ado-build-agent" {
  count                        = var.enable_private_networks ? 1 : 0
  source                       = "github.com/ensono/terraform-azurerm-ado-build-agent"
  vmss_name                    = module.label_default.id
  vmss_resource_group_name     = module.networking[0].vnets[local.hub_network_name].vnet_resource_group_name
  vmss_resource_group_location = var.resource_group_location
  vnet_name                    = module.networking[0].hub_net_name
  vnet_resource_group          = module.networking[0].vnets[local.hub_network_name].vnet_resource_group_name
  subnet_name                  = var.vmss_subnet_name
  vmss_instances               = var.vmss_instances
  vmss_admin_username          = var.vmss_admin_username
  vmss_disable_password_auth   = var.vmss_disable_password_auth

  # Pass in the id of the LB Backend Address Pool
  vmss_network_profile_lb_backend_pool = var.debug_enabled == true ? azurerm_lb_backend_address_pool.debug[0].id : ""
  vmss_network_profile_lb_nat_rule     = var.debug_enabled == true ? azurerm_lb_nat_pool.debug[0].id : ""

  # Configure ADO Agent settings
  ado_agent_pool = local.ado_agent_pool_name
  ado_org_url    = var.ado_org_url
  ado_pat        = var.ado_pat
  ado_project_id = var.ado_project_id

  # Configure debugging
  debug_enabled      = var.debug_enabled
  vmss_admin_ssh_key = var.vmss_admin_ssh_key

  depends_on = [
    azuredevops_agent_pool.ado_agent_pool,
    azurerm_lb_nat_pool.debug,
    module.networking
  ]
}
