
# Naming convention
module "default_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace  = format("%s-%s", var.name_company, var.name_project)
  stage      = var.stage
  name       = "${lookup(var.location_name_map, var.resource_group_location)}-${var.name_component}"
  attributes = var.attributes
  delimiter  = "-"
  tags       = var.tags
}


resource "azurerm_resource_group" "default" {
  name     = module.default_label.id
  location = var.resource_group_location
  tags     = module.default_label.tags
}

# KV for ADF
module "kv_default" {
  source                    = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-kv?ref=v1.5.3"
  resource_namer            = substr(replace(module.default_label.id, "-", ""), 0, 24)
  resource_group_name       = azurerm_resource_group.default.name
  resource_group_location   = azurerm_resource_group.default.location
  create_kv_networkacl      = false
  enable_rbac_authorization = false
  resource_tags             = module.default_label.tags

}

# module call for ADF
module "adf" {
  source                  = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-adf?ref=v1.5.3"
  resource_namer          = module.default_label.id
  resource_group_name     = azurerm_resource_group.default.name
  resource_group_location = azurerm_resource_group.default.location
  git_integration         = var.git_integration
  resource_tags           = module.default_label.tags
}


resource "azurerm_role_assignment" "kv_role" {
  scope                = module.kv_default.id
  role_definition_name = var.kv_role_adf
  principal_id         = module.adf.adf_managed_identity
}

resource "azurerm_role_assignment" "storage_role" {
  scope                = module.adls_default.storage_account_ids[0]
  role_definition_name = var.adls_datalake_role_adf
  principal_id         = module.adf.adf_managed_identity
}

resource "azurerm_role_assignment" "storage_role_config" {
  scope                = module.adls_default.storage_account_ids[1]
  role_definition_name = var.blob_dataconfig_role_adf
  principal_id         = module.adf.adf_managed_identity
}
resource "azurerm_log_analytics_workspace" "la" {
  name                = module.default_label.id
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = var.la_sku
  retention_in_days   = var.la_retention
  tags           = module.default_label.tags
}

# Enable diagnostic settings for ADF
data "azurerm_monitor_diagnostic_categories" "adf_log_analytics_categories" {
  resource_id = module.adf.adf_factory_id
}

resource "azurerm_monitor_diagnostic_setting" "adf_log_analytics" {
  name                           = "ADF to Log Analytics"
  target_resource_id             = module.adf.adf_factory_id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.la.id
  log_analytics_destination_type = "Dedicated"

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.adf_log_analytics_categories.logs

    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.adf_log_analytics_categories.metrics

    content {
      category = metric.value
      enabled  = true

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }
}


# Storage accounts for data lake and config
module "adls_default" {

  source                  = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-adls?ref=v1.5.3"
  resource_namer          = module.default_label.id
  resource_group_name     = azurerm_resource_group.default.name
  resource_group_location = azurerm_resource_group.default.location
  storage_account_details = var.storage_account_details
  container_access_type   = var.container_access_type
  resource_tags           = module.default_label.tags


}


# ADF linked Services
resource "azurerm_data_factory_linked_service_key_vault" "linked_kv" {
  name            = "data_kv_link"
  data_factory_id = module.adf.adf_factory_id
  key_vault_id    = module.kv_default.id
}


resource "azurerm_data_factory_linked_service_azure_blob_storage" "linked_blob" {
  name             = "blob_dataconfig"
  data_factory_id  = module.adf.adf_factory_id
  service_endpoint = module.adls_default.primary_blob_endpoints[0]

}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "linked_adls" {
  name                 = "adls_datalake"
  data_factory_id      = module.adf.adf_factory_id
  use_managed_identity = true
  url                  = module.adls_default.primary_dfs_endpoints[1]
}
