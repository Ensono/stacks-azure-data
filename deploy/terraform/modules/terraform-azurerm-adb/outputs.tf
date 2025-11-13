output "adb_databricks_id" {
  value = azurerm_databricks_workspace.example.id
}

output "databricks_hosturl" {
  description = "Azure Databricks HostUrl"
  value       = "https://${azurerm_databricks_workspace.example.workspace_url}/"
}
