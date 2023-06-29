variable "data_factory" {
  type        = string
  default     = "amido-stacks-dev-euw-rs"
  description = "The name of the Azure datafactory."
}

variable "data_factory_resource_group_name" {

  type        = string
  default     = "amido-stacks-dev-euw-de"
  description = "The name of the resource group for the datafactory "
}

variable "ls_Blob_ConfigStore_properties_typeProperties_serviceEndpoint" {
  type        = string
  default     = "https://amidostacksdeveuwdeconfr.blob.core.windows.net/"
  description = "Blob Config Url for ADF."
}

variable "adlsStorageAccountName" {
  type        = string
  default     = "amidostacksdeveuwdeadls"
  description = "ADLS storage account name."
}


variable "blobStorageAccountName" {
  type        = string
  default     = "amidostacksdeveuwdeconfi"
  description = "Blob Config Url for ADF."
}


variable "databricksHost" {
  type        = string
  default     = "https://adb-XXXXXXXXXXXX.azuredatabricks.net"
  description = "Databricks Host url id"
}


variable "databricksWorkspaceResourceId" {
  type        = string
  default     = "/subscriptions/XXXXXXXXXXXXX/resourceGroups/XXXXXXXXXXX/providers/Microsoft.Databricks/workspaces/XXXXXXX"
  description = "Azure Databricks resource id."
}


variable "ls_ADLS_DataLake_properties_typeProperties_url" {
  type        = string
  default     = "https://amidostacksdeveuwdeadls.dfs.core.windows.net/"
  description = "ADLs connection string."
}


variable "ls_KeyVault_properties_typeProperties_baseUrl" {
  type        = string
  default     = "https://amidostacksdeveuwde.vault.azure.net/"
  description = "KV url."
}


variable "ls_AzureSql_ExampleSource_connectionString" {
  type        = string
  default     = "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=amidostacksdeveuwdesql.database.windows.net;Initial Catalog=sqldbtest;User ID=mssqladmin"
  description = "Sql Connection String."
}

variable "enableDataQualityIngest" {
  type        = bool
  default     = true
  description = "Enable Data Quality Ingest."
}
