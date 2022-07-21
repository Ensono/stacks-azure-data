output "ADLS_STORAGE_ACCOUNT_NAME" {
  value = module.adls.adls_storage_account_id
}

output "ADF_BLOB_LINKED_SERVICE_NAME" {
  description = "BLOB Linked Service Name"
  value       = "ls_blob"
}

output "ADF_STORAGE_ACCOUNT_NAME" {
  description = "The name of the ADF Storage Account"
  value       = var.default_storage_account_name
}

output "RESOURCE_GROUP_NAME" {
  description = "Resource Group name."
  value       = azurerm_resource_group.default.name
}

output "ADF_ACCOUNT_NAME" {
  description = "Azure Data Factory Name"
  value       = module.adf.ADF_ACCOUNT_NAME
}
