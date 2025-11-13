# module call for ADF
module "adf" {
  # source                          = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-adf?ref=v3.0.13"
  source                          = "../modules/terraform-azurerm-adf"
  resource_namer                  = module.label_default.id
  resource_group_name             = azurerm_resource_group.default.name
  resource_group_location         = azurerm_resource_group.default.location
  git_integration                 = var.git_integration
  resource_tags                   = module.label_default.tags
  repository_name                 = var.repository_name
  root_folder                     = var.root_folder
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  ir_enable_interactive_authoring = false
}
