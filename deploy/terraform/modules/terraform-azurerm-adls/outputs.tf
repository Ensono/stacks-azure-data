output "storage_account_ids" {
  value = values(azurerm_storage_account.storage_account_default)[*].id
}

output "storage_account_names" {
  value = values(azurerm_storage_account.storage_account_default)[*].name
}

output "storage_account_id_1" {
  value = values(azurerm_storage_account.storage_account_default)[0].id
}

output "storage_account_primary_connection_string" {
  value     = values(azurerm_storage_account.storage_account_default)[*].primary_connection_string
  sensitive = true
}

output "primary_blob_connection_string" {
  value     = values(azurerm_storage_account.storage_account_default)[*].primary_connection_string
  sensitive = true
}

output "primary_blob_endpoints" {
  value     = values(azurerm_storage_account.storage_account_default)[*].primary_blob_endpoint
  sensitive = true
}

output "primary_dfs_endpoints" {
  value     = values(azurerm_storage_account.storage_account_default)[*].primary_dfs_endpoint
  sensitive = true
}

output "primary_access_key" {
  value     = values(azurerm_storage_account.storage_account_default)[*].primary_access_key
  sensitive = true
}
