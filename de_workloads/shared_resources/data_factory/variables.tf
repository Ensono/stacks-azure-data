variable "data_factory" {
  type        = string
  description = "Azure Data Factory name"
}

variable "data_factory_resource_group_name" {
  type        = string
  description = "Azure Data Factory resource group name"
}

variable "key_vault_resource_group_name" {
  type        = string
  description = "Azure Key Vault resource group name"
}

variable "key_vault_name" {
  type        = string
  description = "Azure Key Vault URI, e.g. amidostacksdeveuwde"
}

variable "integration_runtime_name" {
  type        = string
  description = "Azure Data Factory Integration Runtime name, e.g. adf-managed-vnet-runtime"
}

variable "blob_configstore_name" {
  type        = string
  description = "Blob storage Config Store - storage account name, e.g. amidostacksdeveuwdeconfi"
}

variable "blob_configstore_endpoint" {
  type        = string
  description = "Blob storage Config Store - service endpoint, e.g. https://amidostacksdeveuwdeconfi.blob.core.windows.net/"
}

variable "adls_datalake_name" {
  type        = string
  description = "Azure Data Lake Storage - storage account name, e.g. amidostacksdeveuwdeadls"
}

variable "adls_datalake_url" {
  type        = string
  description = "Azure Data Lake Storage - URL, e.g. https://amidostacksdeveuwdeadls.dfs.core.windows.net/"
}

variable "include_databricks_resources" {
  type        = bool
  description = "Include Databricks resources (e.g. linked services) in Data Factory"
}

variable "databricks_workspace_url" {
  type        = string
  description = "Databricks - Workspace URL, e.g. https://adb-XXXXXXXXXXXX.azuredatabricks.net"
  default     = null
}

variable "databricks_workspace_resource_id" {
  type        = string
  description = "Databricks - Workspace Resource ID, e.g. /subscriptions/XXXXXXXXXXXXX/resourceGroups/XXXXXXXXXXX/providers/Microsoft.Databricks/workspaces/XXXXXXX"
  default     = null
}

variable "arm_deployment_mode" {
  type        = string
  description = "Deployment mode for any ARM resources"
  default     = "Incremental"
}
