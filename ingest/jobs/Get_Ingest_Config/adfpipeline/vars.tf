variable "data_factory" {
  type        = string
  default     = "amido-stacks-dev-euw"
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
