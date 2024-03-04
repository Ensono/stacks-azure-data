output "resource_group_name" {
  description = "Name of the resource group that things have been deployed into"
  value       = azurerm_resource_group.default.name
  depends_on  = [azurerm_resource_group.default]
}

output "adf_name" {
  description = "Name of the Azure Databricks instance that has been created"
  value       = module.adf.adf_account_name
}

output "adf_integration_runtime_name" {
  description = "Name of the integration runtime name"
  value       = module.adf.adf_integration_runtime_name
}

output "adls_storage_accounts" {
  description = "List of generated storage accounts"
  value       = module.adls_default.storage_account_names
}

output "adls_storage_account_endpoints" {
  value     = module.adls_default.primary_blob_endpoints
  sensitive = true
}

output "adls_dfs-endpoints" {
  value     = module.adls_default.primary_dfs_endpoints
  sensitive = true
}

output "adb_databricks_id" {
  value = module.adb.adb_databricks_id
}

output "adb_host_url" {
  value = module.adb.databricks_hosturl
}

output "kv_name" {
  value = module.kv_default.key_vault_name
}
