variable "data_factory" {
  type        = string
  default     = "amido-stacks-dev-euw-de"
  description = "The name of the Azure datafactory."
}

variable "data_factory_resource_group_name" {

  type        = string
  default     = "amido-stacks-dev-euw-de"
  description = "The name of the resource group for the datafactory "
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
  default     = "/subscriptions/XXXXXXXXXXXXX/resourceGroups/XXXXXXXXXXX/providers/Microsoft.Databricks/workspaces/XXXXXXX"   #"/subscriptions/XXXXXXXXXXXXX/resourceGroups/XXXXXXXXXXX/providers/Microsoft.Databricks/workspaces/XXXXXXX"
  description = "Azure Databricks resource id."
}

variable "enableDataQualitySilver" {
  type        = bool
  default     = true
  description = "Enable Data Quality Ingest."
}

variable "azureClientID" {
  type        = string
  default     = "{{secrets/key-vault-secret/azure-client-id}}"
  description = "Databricks Host url id"
}