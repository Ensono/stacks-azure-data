variable "data_factory_id" {
  type        = string
  description = "Azure Data Factory ID"
}

variable "integration_runtime_name" {
  type        = string
  description = "Azure Data Factory Integration Runtime name"
}

variable "blob_configstore_name" {
  type        = string
  description = "Blob storage Config Store - storage account name"
}

variable "blob_configstore_endpoint" {
  type        = string
  description = "Blob storage Config Store - service endpoint"
}

variable "adls_datalake_name" {
  type        = string
  description = "ADLS Data Lake - storage account name"
}

variable "adls_datalake_url" {
  type        = string
  description = "ADLS Data Lake - URL"
}

variable "include_databricks_resources" {
  type        = bool
  description = "Include Databricks resources (e.g. linked services) in Data Factory"
}

variable "databricks_workspace_url" {
  type        = string
  description = "Databricks - Workspace URL"
  default     = null
}

variable "databricks_workspace_resource_id" {
  type        = string
  description = "Databricks - Workspace Resource ID"
  default     = null
}
