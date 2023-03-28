############################################
# NAMING
############################################

variable "name_company" {
  description = "Company Name - should/will be used in conventional resource naming"
  type        = string
}

variable "name_project" {
  description = "Project Name - should/will be used in conventional resource naming"
  type        = string
}

variable "name_component" {
  description = "Component Name - should/will be used in conventional resource naming. Typically this will be a logical name for this part of the system i.e. `API` || `middleware` or more generic like `Billing`"
  type        = string
  default     = "data"
}


variable "stage" {
  type    = string
  default = "dev"
}

variable "attributes" {
  description = "Additional attributes for tagging"
  default     = []
}

variable "tags" {
  description = "Tags to be assigned to all resources, NB if global tagging is enabled these will get overwritten periodically"
  type        = map(string)
  default     = {}
}


variable "resource_group_location" {
  type    = string
  default = "uksouth"

}


# Each region must have corresponding a shortend name for resource naming purposes 
variable "location_name_map" {
  type = map(string)

  default = {
    northeurope   = "eun"
    westeurope    = "euw"
    uksouth       = "uks"
    ukwest        = "ukw"
    eastus        = "use"
    eastus2       = "use2"
    westus        = "usw"
    eastasia      = "ase"
    southeastasia = "asse"
  }
}

variable "git_integration" {
  type        = string
  default     = "null"
  description = "A repository integration block for ADF git integration. Can be null, github or vsts."
  validation {
    condition     = can(regex("^null$|^github$|^vsts$", var.git_integration))
    error_message = "Err: git integration value is not valid. It can be null, github, vsts."
  }
}

# Log Analytics workspace Details

variable "la_sku" {
  type        = string
  default     = "PerGB2018"
  description = "Specifies the SKU of the Log Analytics Workspace."
}

variable "la_retention" {
  type        = number
  default     = 30
  description = "The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
}

############################################
# Storage Account Details 
############################################

variable "storage_account_details" {
  type = map(object({
    account_tier    = string
    account_kind    = string
    name            = string
    hns_enabled     = bool
    containers_name = list(string)
  }))
  default = {
    "data_config_storage" = {
      account_kind    = "BlobStorage"
      account_tier    = "Standard"
      hns_enabled     = false
      name            = "config"
      containers_name = ["config"]
    },
    "data_lake_storage" = {
      account_kind    = "StorageV2"
      account_tier    = "Standard"
      hns_enabled     = true
      name            = "adls"
      containers_name = ["curated", "staging", "raw"]
    },
  }
}

############################################
# Role assignments for ADF
############################################

variable "adls_datalake_role_adf" {
  description = "Role assignment for ADLS Gen2 storage."
  type        = string
  default     = "Storage Blob Data Contributor"
}

variable "blob_dataconfig_role_adf" {
  description = "Role assignment for config blob storage."
  type        = string
  default     = "Storage Blob Data Contributor"
}

variable "kv_role_adf" {
  description = "Role assignment for Key Vault."
  type        = string
  default     = "Key Vault Secrets User"
}

############################################
# Containers for Storage Accounts
############################################
variable "container_access_type" {
  type        = string
  description = "value"
  default     = "private"
}


variable "kv_secrets" {
  type        = list(string)
  description = "Specifies the name of the Key Vault Secrets. The secrets' values will need to be updated directly once deployed. Existing secrets with the same name will not be overwritten."
  default     = ["secret1", "secret2", "secret3"]
}


variable "contributor_object_ids" {
  description = "A list of Azure active directory user,group or application object ID's that will have contributor role to the key vault"
  type        = list(string)
  default     = []
}
