# # Naming convention
 module "default_label" {
   source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
   namespace  = format("%s-%s", var.name_company, var.name_project)
   stage      = var.stage
   name       = "${lookup(var.location_name_map, var.resource_group_location, "uksouth")}-${var.name_component}"
   attributes = var.attributes
   delimiter  = "-"
   tags       = var.tags
 }

 module "adf" {
   source = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-data/adf?ref=v0.1.0"
   region                                        = var.region
   data_factory_name                             = var.data_factory_name
   data_platform_log_analytics_workspace_id      = var.data_platform_log_analytics_workspace_id
   platform_scope                                = var.platform_scope
   resource_group_name                           = azurerm_resource_group.default.name
   adls_storage_account_id                       = module.adls.adls_storage_account_id
   default_storage_account_id                    = module.adls.default_storage_account_id
   adls_storage_account_primary_dfs_endpoint     = module.adls.adls_storage_account_primary_dfs_endpoint
   default_storage_account_primary_blob_endpoint = module.adls.default_storage_account_primary_blob_endpoint
 }

 module "adls" {
   source = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-data/adls?ref=v0.1.0"
   adls_storage_account_name    = var.adls_storage_account_name
   default_storage_account_name = var.default_storage_account_name
   platform_scope               = var.platform_scope
   region                       = var.region
   resource_group_name          = azurerm_resource_group.default.name
 }
