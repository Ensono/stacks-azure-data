# # Naming convention
 module "default_label" {
   source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
   namespace  = format("%s-%s", var.name_company, var.name_project)
   stage      = var.stage
   name       = "${lookup(var.location_name_map, var.resource_group_location, "westeurope")}-${var.name_component}"
   attributes = var.attributes
   delimiter  = "-"
   tags       = var.tags
 }

 module "app" {
   source = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-data?ref=v0.1.0"
   resource_namer                                = module.default_label.id
   resource_tags                                 = module.default_label.tags
   resource_group_location                       = var.resource_group_location 
   data_factory_name                             = var.data_factory_name
   core_resource_group                           = data.terraform_remote_state.core.outputs.resource_group_name
   adls_storage_account_id                       = module.adls.adls_storage_account_id
   default_storage_account_id                    = module.adls.default_storage_account_id
   adls_storage_account_primary_dfs_endpoint     = module.adls.adls_storage_account_primary_dfs_endpoint
   default_storage_account_primary_blob_endpoint = module.adls.default_storage_account_primary_blob_endpoint
   adls_storage_account_name                     = var.adls_storage_account_name
   default_storage_account_name                  = var.default_storage_account_name
   subscription_id                               = data.azurerm_client_config.current.subscription_id
 }
