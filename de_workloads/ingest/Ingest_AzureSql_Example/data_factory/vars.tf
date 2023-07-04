variable "data_factory" {
  type        = string
  description = "Azure Data Factory name"
}

variable "data_factory_resource_group_name" {

  type        = string
  description = "Azure Data Factory resource group name"
}

variable "azuresql_examplesource_connectionstring" {
  type        = string
  description = "Azure SQL Example Source - connection string"
}

variable "key_vault_linked_service_name" {
  type        = string
  description = "ADF Key Vault linked service name"
}

variable "include_data_quality" {
  type        = bool
  description = "Include data quality step in pipeline"
}
