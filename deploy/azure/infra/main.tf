
# Create a random string as a suffix to the end of the SQL name
# this is to help when destorying and redeploying instances
resource "random_string" "sqlsuffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

# Naming convention
module "default_label" {
  source          = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace       = format("%s-%s", substr(var.name_company, 0, 16), substr(var.name_project, 0, 16))
  stage           = var.stage
  name            = "${lookup(var.location_name_map, var.resource_group_location)}-${substr(var.name_component, 0, 16)}"
  attributes      = concat([random_string.sqlsuffix.result], var.attributes)
  delimiter       = "-"
  id_length_limit = 60
  tags            = var.tags
}

//This module should be used to generate names for resources that have limits:
//// Between 3 and 24 characters long.
//// Lowercase letters or numbers.
//// Storage Account names must be globally unique.
module "default_label_short" {
  source              = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace           = format("%s-%s", substr(var.name_company, 0, 4), substr(var.name_project, 0, 4))
  stage               = var.stage
  name                = "${lookup(var.location_name_map, var.resource_group_location)}-${substr(var.name_component, 0, 6)}"
  attributes          = concat([random_string.sqlsuffix.result], var.attributes)
  delimiter           = ""
  tags                = var.tags
  id_length_limit     = 20
  regex_replace_chars = "/[^a-zA-Z0-9]/"
}

resource "azurerm_resource_group" "default" {
  name     = module.default_label.id
  location = var.resource_group_location
  tags     = module.default_label.tags
}

# KV for ADF
module "kv_default" {
  source                        = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-kv?ref=v3.0.13"
  resource_namer                = substr(module.default_label_short.id, 0, 24)
  resource_group_name           = azurerm_resource_group.default.name
  resource_group_location       = azurerm_resource_group.default.location
  create_kv_networkacl          = true
  enable_rbac_authorization     = false
  resource_tags                 = module.default_label_short.tags
  contributor_object_ids        = concat(var.contributor_object_ids, [data.azurerm_client_config.current.object_id])
  enable_private_network        = var.enable_private_networks
  pe_subnet_id                  = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].id) : ""
  pe_resource_group_name        = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].resource_group_name) : ""
  pe_resource_group_location    = var.pe_resource_group_location
  dns_resource_group_name       = local.dns_zone_resource_group_name
  public_network_access_enabled = var.enable_private_networks ? var.kv_public_network_access_enabled : true # enabled if only public network otherwise cannot connect
  kv_private_dns_zone_id        = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.kv_private_dns_zone[0].id) : ""
  virtual_network_subnet_ids    = var.enable_private_networks ? [tostring(data.azurerm_subnet.pe_subnet[0].id)] : []
  network_acl_default_action    = "Allow"
  reader_object_ids             = [module.adf.adf_managed_identity]

  depends_on = [module.adf]
}

# module call for ADF
module "adf" {
  source                          = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-adf?ref=v3.0.13"
  resource_namer                  = module.default_label.id
  resource_group_name             = azurerm_resource_group.default.name
  resource_group_location         = azurerm_resource_group.default.location
  git_integration                 = var.git_integration
  resource_tags                   = module.default_label.tags
  repository_name                 = var.repository_name
  root_folder                     = var.root_folder
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  ir_enable_interactive_authoring = false
}

###########  Private Endpoints for ADF to connect to Azure services ######################
resource "azurerm_data_factory_managed_private_endpoint" "blob_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_blob
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.adls_default.storage_account_ids[0]
  subresource_name   = "blob"
}

resource "azurerm_data_factory_managed_private_endpoint" "adls_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_dfs
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.adls_default.storage_account_ids[1]
  subresource_name   = "dfs"
}

resource "azurerm_data_factory_managed_private_endpoint" "kv_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_kv
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.kv_default.id
  subresource_name   = "vault"
}

resource "azurerm_data_factory_managed_private_endpoint" "sql_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_sql
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.sql.sql_server_id
  subresource_name   = "sqlServer"
}

resource "azurerm_data_factory_managed_private_endpoint" "db_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = var.name_pe_db
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.adb.adb_databricks_id
  subresource_name   = "databricks_ui_api"

  depends_on = [module.adb]
}

resource "azurerm_data_factory_managed_private_endpoint" "db_auth_pe" {
  count              = var.enable_private_networks ? 1 : 0
  name               = "${var.name_pe_db}_auth"
  data_factory_id    = module.adf.adf_factory_id
  target_resource_id = module.adb.adb_databricks_id
  subresource_name   = "browser_authentication"

  depends_on = [module.adb]
}

resource "null_resource" "approve_private_endpoints" {
  for_each = local.private_endpoint_list

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
        az login --service-principal -u ${data.azurerm_client_config.current.client_id} -p ${var.azure_client_secret} --tenant ${data.azurerm_client_config.current.tenant_id}
        text=$(az network private-endpoint-connection list --id ${each.value})
        pendingPE=`echo $text | jq -r '.[] | select(.properties.privateLinkServiceConnectionState.status == "Pending") | .id'`
        for id in $pendingPE
        do
            echo "$id is in a pending state"
            az network private-endpoint-connection approve --id "$id" --description "Approved"
        done
    EOT
  }
  depends_on = [azurerm_data_factory_managed_private_endpoint.db_auth_pe, azurerm_data_factory_managed_private_endpoint.db_pe, azurerm_data_factory_managed_private_endpoint.sql_pe, azurerm_data_factory_managed_private_endpoint.kv_pe, azurerm_data_factory_managed_private_endpoint.adls_pe, azurerm_data_factory_managed_private_endpoint.blob_pe]
}


resource "azurerm_role_assignment" "kv_role" {
  scope                = module.kv_default.id
  role_definition_name = var.kv_role_adf
  principal_id         = module.adf.adf_managed_identity
}

resource "azurerm_role_assignment" "sql_role" {
  scope                = module.sql.sql_server_id
  role_definition_name = var.sql_role_adf
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
    for_each = data.azurerm_monitor_diagnostic_categories.adf_log_analytics_categories.log_category_types

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

  source                        = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-adls?ref=v3.0.13"
  resource_namer                = module.default_label_short.id
  resource_group_name           = azurerm_resource_group.default.name
  resource_group_location       = azurerm_resource_group.default.location
  storage_account_details       = var.storage_account_details
  container_access_type         = var.container_access_type
  resource_tags                 = module.default_label_short.tags
  enable_private_network        = var.enable_private_networks
  pe_subnet_id                  = var.enable_private_networks ? lower(tostring(data.azurerm_subnet.pe_subnet[0].id)) : ""
  pe_resource_group_name        = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].resource_group_name) : ""
  pe_resource_group_location    = var.pe_resource_group_location
  dfs_dns_resource_group_name   = local.dns_zone_resource_group_name
  blob_dns_resource_group_name  = local.dns_zone_resource_group_name
  blob_private_dns_zone_name    = var.blob_private_dns_zone_name
  dfs_private_dns_zone_name     = var.dfs_private_dns_zone_name
  public_network_access_enabled = !var.enable_private_networks
  dfs_private_zone_id           = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.dfs_private_zone[0].id) : ""
  blob_private_zone_id          = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.blob_private_zone[0].id) : ""
  azure_object_id               = data.azurerm_client_config.current.object_id
}

# Storage accounts for data lake and config
module "sql" {
  source                        = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-sql?ref=v3.0.13"
  resource_namer                = format("%s%s", module.default_label.id, random_string.sqlsuffix.result)
  resource_group_name           = azurerm_resource_group.default.name
  resource_group_location       = azurerm_resource_group.default.location
  sql_version                   = var.sql_version
  administrator_login           = var.administrator_login
  sql_db_names                  = var.sql_db_names
  resource_tags                 = module.default_label.tags
  enable_private_network        = var.enable_private_networks
  pe_subnet_id                  = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].id) : ""
  pe_resource_group_name        = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].resource_group_name) : ""
  pe_resource_group_location    = var.pe_resource_group_location
  dns_resource_group_name       = local.dns_zone_resource_group_name
  public_network_access_enabled = var.sql_public_network_access_enabled
  //As the default SKU in the module is basic, we need to set this to 0 otherwise it defaults to 60 and never gets applied.
  auto_pause_delay_in_minutes = 0
}

module "adb" {
  source                                   = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-adb?ref=v3.0.13"
  resource_namer                           = module.default_label.id
  resource_group_name                      = azurerm_resource_group.default.name
  resource_group_location                  = azurerm_resource_group.default.location
  databricks_sku                           = var.databricks_sku
  resource_tags                            = module.default_label.tags
  enable_databricksws_diagnostic           = false #var.enable_databricksws_diagnostic
  data_platform_log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  databricksws_diagnostic_setting_name     = var.databricksws_diagnostic_setting_name
  enable_private_network                   = var.enable_private_networks
  create_pe_subnet                         = false
  create_subnets                           = true
  vnet_name                                = var.vnet_name
  vnet_resource_group                      = var.vnet_resource_group_name
  virtual_network_id                       = var.enable_private_networks ? tostring(data.azurerm_virtual_network.vnet[0].id) : ""
  public_subnet_name                       = var.public_subnet_name
  private_subnet_name                      = var.private_subnet_name
  pe_subnet_name                           = var.pe_subnet_name
  public_subnet_prefix                     = var.public_subnet_prefix
  private_subnet_prefix                    = var.private_subnet_prefix
  pe_subnet_prefix                         = var.pe_subnet_prefix
  pe_subnet_id                             = var.enable_private_networks ? data.azurerm_subnet.pe_subnet[0].id : ""
  public_network_access_enabled            = var.public_network_access_enabled
  create_nat                               = false
  create_lb                                = false
  managed_vnet                             = !var.enable_private_networks
  browser_authentication_enabled           = var.browser_authentication_enabled
  private_dns_zone_id                      = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.adb_private_dns_zone[0].id) : ""

  depends_on = [azurerm_resource_group.default]
}


resource "azurerm_role_assignment" "adb_role" {
  scope                = module.adb.adb_databricks_id
  role_definition_name = var.adb_role_adf
  principal_id         = module.adf.adf_managed_identity
}


resource "databricks_token" "pat" {
  comment = var.databricks_pat_comment
  // 120 day token
  lifetime_seconds = 120 * 24 * 60 * 60
  depends_on       = [module.adb]
}

resource "azurerm_key_vault_secret" "databricks_token" {
  name         = var.databricks-token
  value        = databricks_token.pat.token_value
  key_vault_id = module.kv_default.id
  depends_on   = [module.adb, module.kv_default]
}


resource "azurerm_key_vault_secret" "databricks-host" {
  name         = var.databricks-host
  value        = module.adb.databricks_hosturl
  key_vault_id = module.kv_default.id
  depends_on   = [module.adb, module.kv_default]
}

resource "databricks_secret_scope" "kv" {
  name = var.databricks_secret_scope_kv

  keyvault_metadata {
    resource_id = module.kv_default.id
    dns_name    = module.kv_default.vault_uri
  }
  depends_on = [module.adb, module.kv_default]
}

resource "databricks_workspace_conf" "this" {
  count = var.databricks_enableDbfsFileBrowser ? 1 : 0
  custom_config = {
    "enableDbfsFileBrowser" : "true"
  }
  depends_on = [module.adb]
}

# Add secrets to KV. Please note this is just going to add secret names to KV. The actual value of that secret needs to be updated manually in Azure Key Vault. Existing secrets with the same name will not be overwritten.
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = toset(var.kv_secrets)
  name         = each.key
  value        = ""
  key_vault_id = module.kv_default.id

  depends_on = [module.kv_default, azurerm_private_dns_zone_virtual_network_link.privatelink-dns["privatelink.vaultcore.azure.net"]]
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = var.sql_password
  value        = module.sql.sql_sa_password
  key_vault_id = module.kv_default.id
  depends_on   = [module.kv_default, azurerm_private_dns_zone_virtual_network_link.privatelink-dns["privatelink.vaultcore.azure.net"]]
}

resource "azurerm_key_vault_secret" "sql_connect_string" {
  for_each     = toset(var.sql_db_names)
  name         = "connect-string-${each.key}"
  value        = "Server=tcp:${module.sql.sql_server_name}.database.windows.net,1433;Database=${each.key};User ID=${module.sql.sql_sa_login};Password=${module.sql.sql_sa_password};Trusted_Connection=False;Encrypt=True;Connection Timeout=30"
  key_vault_id = module.kv_default.id
  depends_on   = [module.kv_default, azurerm_private_dns_zone_virtual_network_link.privatelink-dns["privatelink.vaultcore.azure.net"]]
}

resource "azurerm_key_vault_secret" "sql_password_string" {
  for_each     = toset(var.sql_db_names)
  name         = "connect-sql-password-${each.key}"
  value        = module.sql.sql_sa_password
  key_vault_id = module.kv_default.id
  depends_on   = [module.kv_default, azurerm_private_dns_zone_virtual_network_link.privatelink-dns["privatelink.vaultcore.azure.net"]]
}

resource "azurerm_key_vault_secret" "service-principal-secret" {
  name         = "service-principal-secret"
  value        = var.azure_client_secret
  key_vault_id = module.kv_default.id
  depends_on   = [module.kv_default, azurerm_private_dns_zone_virtual_network_link.privatelink-dns["privatelink.vaultcore.azure.net"]]
}

resource "azurerm_key_vault_secret" "azure-client-id" {
  name         = "azure-client-id"
  value        = data.azurerm_client_config.current.client_id
  key_vault_id = module.kv_default.id
  depends_on   = [module.kv_default, azurerm_private_dns_zone_virtual_network_link.privatelink-dns["privatelink.vaultcore.azure.net"]]
}

resource "azurerm_key_vault_secret" "azure-tenant-id" {
  name         = "azure-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = module.kv_default.id
  depends_on   = [module.kv_default, azurerm_private_dns_zone_virtual_network_link.privatelink-dns["privatelink.vaultcore.azure.net"]]
}
