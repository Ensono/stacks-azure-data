variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group name"
}

variable "adf_account_name" {
  type        = string
  description = "Azure Data Factory account name"
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
