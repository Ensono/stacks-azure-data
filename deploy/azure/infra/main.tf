
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
  source                    = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-kv?ref=v1.5.4"
  resource_namer            = substr(replace(module.default_label.id, "-", ""), 0, 24)
  resource_group_name       = azurerm_resource_group.default.name
  resource_group_location   = azurerm_resource_group.default.location
  create_kv_networkacl      = false
  enable_rbac_authorization = false
  resource_tags             = module.default_label.tags
  contributor_object_ids    = concat(var.contributor_object_ids, [data.azurerm_client_config.current.object_id])
}

# module call for ADF
module "adf" {
  source                  = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-adf?ref=v1.5.5"
  resource_namer          = module.default_label.id
  resource_group_name     = azurerm_resource_group.default.name
  resource_group_location = azurerm_resource_group.default.location
  git_integration         = var.git_integration
  resource_tags           = module.default_label.tags
  repository_name         = var.repository_name
  root_folder             = var.root_folder
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
  tags                = module.default_label.tags
}

#Below role assingment is needed to run end to end Test in pipeline
resource "azurerm_role_assignment" "e_2_test_role" {
  scope                = module.adls_default.storage_account_ids[1]
  role_definition_name = var.e_2_test_role
  principal_id         = data.azurerm_client_config.current.object_id
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

  source                  = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-adls?ref=v1.5.4"
  resource_namer          = module.default_label.id
  resource_group_name     = azurerm_resource_group.default.name
  resource_group_location = azurerm_resource_group.default.location
  storage_account_details = var.storage_account_details
  container_access_type   = var.container_access_type
  resource_tags           = module.default_label.tags


}


# Add secrets to KV. Please note this is just going to add secret names to KV. The actual value of that secret needs to be updated manually in Azure Key Vault. Existing secrets with the same name will not be overwritten.
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = toset(var.kv_secrets)
  name         = each.key
  value        = ""
  key_vault_id = module.kv_default.id
  lifecycle {
    ignore_changes = [

      value, version
    ]
  }
  depends_on = [module.kv_default]
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = var.sql_password
  value        = module.sql.sql_sa_password
  key_vault_id = module.kv_default.id
}


# Storage accounts for data lake and config
module "sql" {
  source                  = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-sql?ref=master"
  resource_namer          = module.default_label.id
  resource_group_name     = azurerm_resource_group.default.name
  resource_group_location = azurerm_resource_group.default.location
  sql_version             = var.sql_version
  administrator_login     = var.administrator_login
  sql_db_names            = var.sql_db_names
  resource_tags           = module.default_label.tags
}

resource "azurerm_key_vault_secret" "sql_connect_string" {
  for_each     = toset(var.sql_db_names)
  name         = "connect-string-${each.key}"
  value        = "Server=tcp:${module.sql.sql_server_name}.database.windows.net,1433;Database=${each.key};User ID=${module.sql.sql_sa_login};Password=${module.sql.sql_sa_password};Trusted_Connection=False;Encrypt=True;Connection Timeout=30"
  key_vault_id = module.kv_default.id
}

# databricks workspace
module "adb" {
  source                                   = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-adb?ref=master"
  resource_namer                           = module.default_label.id
  resource_group_name                      = azurerm_resource_group.default.name
  resource_group_location                  = azurerm_resource_group.default.location
  databricks_sku                           = var.databricks_sku
  resource_tags                            = module.default_label.tags
  enable_databricksws_diagnostic           = var.enable_databricksws_diagnostic
  data_platform_log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  databricksws_diagnostic_setting_name     = var.databricksws_diagnostic_setting_name
  enable_enableDbfsFileBrowser             = var.enable_enableDbfsFileBrowser
  add_rbac_users                           = var.add_rbac_users
  rbac_databricks_users                    = var.rbac_databricks_users
  databricks_group_display_name            = var.databricks_group_display_name
}

resource "azurerm_role_assignment" "adb_role" {
  scope                = module.adb.adb_databricks_id
  role_definition_name = var.adb_role_adf
  principal_id         = module.adf.adf_managed_identity
}

module "networking" {
  source                      = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-hub-spoke?ref=feature/6101-private-adls"
  enable_private_networks     = true ## NOTE setting this value to false will cause no resources to be created !!
  network_details             = var.network_details
  resource_group_name         = azurerm_resource_group.default.name
  resource_group_location     = azurerm_resource_group.default.location
  create_hub_fw               = true
  create_fw_public_ip         = true
  name_az_fw                  = "testfirewall"
  sku_az_fw                   = "AZFW_VNet"
  sku_tier_az_fw              = "Standard"
  hub_fw_address_prefixes     = ["10.2.3.0/26"]
  fw_public_ip_sku            = "Standard"
  fw_public_allocation_method = "Static"
  create_private_dns_zone     = true
  dns_zone_name               = "stacks-de"
}

module "vmss" {
  source                       = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-vmss?ref=feature/vmss-module"
  vmss_name                    = module.default_label.id
  vmss_resource_group_name     = azurerm_resource_group.default.name
  vmss_resource_group_location = azurerm_resource_group.default.location
  vnet_name                    = "data-hub-vnet-test"
  vnet_resource_group          = azurerm_resource_group.default.name
  subnet_name                  = "build-agent"
  vmss_instances               = 0
  vmss_admin_username          = "adminuser"
  vmss_disable_password_auth   = false
  depends_on                   = [module.networking]
}

module "adls_private" {
  source                        = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-adls?ref=feature/6101-private-adls"
  resource_namer                = "${module.default_label.id}1"
  resource_group_name           = azurerm_resource_group.default.name
  resource_group_location       = azurerm_resource_group.default.location
  storage_account_details       = var.storage_account_details
  container_access_type         = var.container_access_type
  resource_tags                 = module.default_label.tags
  public_network_access_enabled = false
  network_rules = [{
    default_action             = "Allow"
    virtual_network_subnet_ids = [module.networking.subnets["spoke_vnet1"].id]
    ip_rules                   = ["40.74.28.0/23", "51.104.26.0/24"]
    bypass                     = ["Metrics", "Logging", "AzureServices"]
  }]
  depends_on = [module.networking]
}

resource "azurerm_role_assignment" "storage_role_private" {
  scope                = module.adls_private.storage_account_ids[0]
  role_definition_name = var.adls_datalake_role_adf
  principal_id         = module.adf.adf_managed_identity
}

resource "azurerm_role_assignment" "storage_role_config_private" {
  scope                = module.adls_private.storage_account_ids[1]
  role_definition_name = var.blob_dataconfig_role_adf
  principal_id         = module.adf.adf_managed_identity
}

resource "azurerm_role_assignment" "storage_role_context" {
  scope                = module.adls_private.storage_account_ids[0]
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
