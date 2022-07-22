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

output "resource_group_name" {
  description = "Name of the core resource group"
  value       = data.terraform_remote_state.core.outputs.resource_group_name
}

output "ADF_ACCOUNT_NAME" {
  description = "Azure Data Factory Name"
  value       = module.adf.ADF_ACCOUNT_NAME
}

output "app_insights_name" {
  description = "Name of the Application Insights instance"
  value       = data.terraform_remote_state.core.outputs.app_insights_name
}
