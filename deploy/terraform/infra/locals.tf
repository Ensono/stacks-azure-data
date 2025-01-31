
locals {

  # Create a list of the items for which endpoints need to be created
  # This only applies if the enable_private_networks is enabled
  private_endpoint_list = var.enable_private_networks ? {
    blob = module.adls_default.storage_account_ids[0]
    adls = module.adls_default.storage_account_ids[1]
    kv   = module.kv_default.id
    sql  = module.sql.sql_server_id
    adb  = module.adb.adb_databricks_id
  } : {}

  dns_zone_resource_group_name = var.dns_zone_resource_group_name != "" ? var.dns_zone_resource_group_name : var.vnet_resource_group_name

  # Each region must have corresponding a shortened name for resource naming purposes
  location_name_map = {
    northeurope   = "eun"
    westeurope    = "euw"
    uksouth       = "uks"
    ukwest        = "ukw"
    eastus        = "use"
    eastus2       = "use2"
    westus        = "usw"
    eastasia      = "ase"
    southeastasia = "asse"
  }

  # Determine the expiration data of the secrets in the key vault
  secret_expiration_date = timeadd(timestamp(), var.kv_secret_expiration)

  # Set the admin password for sql
  # This is either from the variable, if it has been set or from the random_password resource
  sql_admin_password = var.administrator_login != "" ? var.administrator_login : random_password.sql_admin.result

  # determine the prefix for the ado variable group
  # this is so that it is easy to identify in the Azure DevOps UI and cannot be confused with other projects
  # using this template
  tf_stage           = lower(data.external.env.result["STAGE"])
  ado_vg_name_prefix = "${var.name_company}-${var.name_project}-${var.name_component}-${var.environment}-${local.tf_stage}"

  # Create object that will be used for the outputs, this is so that they can be used
  # in different places
  outputs = {
    resource_group_name            = azurerm_resource_group.default.name
    sql_admin_password             = local.sql_admin_password
    adf_name                       = module.adf.adf_account_name
    adf_integration_runtime_name   = module.adf.adf_integration_runtime_name
    adls_storage_accounts          = module.adls_default.storage_account_names
    adls_storage_account_endpoints = module.adls_default.primary_blob_endpoints
    adls_dfs_endpoints             = module.adls_default.primary_dfs_endpoints
    adb_databricks_id              = module.adb.adb_databricks_id
    adb_host_url                   = module.adb.databricks_hosturl
    kv_name                        = module.kv_default.key_vault_name
  }

  # Create a local object for the template mapping so that the script files can be generated
  templates = flatten([
    for file in ["envvars.bash.tpl", "envvars.ps1.tpl", "inputs.tfvars.tpl"] :
    {
      envname  = var.environment
      file     = file
      items    = local.outputs
      template = "${path.module}/../templates/${file}"
    }
  ])
}
