variable "data_factory" {
  type        = string
  description = "Azure Data Factory name"
}

variable "data_factory_resource_group_name" {
  type        = string
  description = "Azure Data Factory resource group name"
}

variable "linked_service_type" {
  type        = string
  description = "Type of Linked Service in Data Factory"
  default     = "AzureSqlDatabase"
}

variable "linked_service_connectionstring" {
  type        = string
  description = "Data source connection string, e.g. Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=amidostacksdeveuwdesql.database.windows.net;Initial Catalog=sqldbtest;User ID=mssqladmin"
}

variable "linked_service_name" {
  type        = string
  description = "Data source linked service name"
  default     = "ls_AzureSql_ExampleSource"
}

variable "linked_service_description" {
  type        = string
  description = "Data source linked service description"
  default     = "Azure SQL example linked service."
}

variable "key_vault_linked_service_name" {
  type        = string
  description = "ADF Key Vault linked service name, e.g. ls_KeyVault"
  default     = "ls_KeyVault"
}

variable "key_vault_secret_name" {
  type        = string
  description = "Name of secret within Azure Key Vault"
  default     = "sql-password"
}

variable "integration_runtime_name" {
  type        = string
  description = "Azure Data Factory Integration Runtime name, e.g. adf-managed-vnet-runtime"
}

variable "dataset_type" {
  type        = string
  description = "Type of Dataset in Data Factory"
  default     = "AzureSqlTable"
}

variable "dataset_name" {
  type        = string
  description = "Name of Dataset in Data Factory"
  default     = "ds_ex_AzureSql_ExampleSource"
}

variable "include_data_quality" {
  type        = bool
  description = "Include data quality step in pipeline"
}

variable "arm_deployment_mode" {
  type        = string
  description = "Deployment mode for any ARM resources"
  default     = "Incremental"
}
