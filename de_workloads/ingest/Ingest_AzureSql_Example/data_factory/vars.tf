variable "data_factory_id" {
  type        = string
  description = "Azure Data Factory ID"
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
