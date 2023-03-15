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

# The name of the Log Analytics workspace to be deployed
variable "la_name" {
  type        = string
  default     = "stacks-la"
  description = "Specify Log Analytics Name "
}

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
# Strorage Account Details 
############################################

variable "storage_account_details" {
  type = map(object({
    account_tier = string
    account_kind = string
    name         = string
    hns_enabled  = bool
  }))
  default = {
    "account1" = {
      account_kind = "BlobStorage"
      account_tier = "Standard"
      hns_enabled  = false
      name         = "config"
    },
    "account2" = {
      account_kind = "StorageV2"
      account_tier = "Standard"
      hns_enabled  = true
      name         = "adls"
    },
  }
}

############################################
# Role Assingments for Adf
############################################

variable "adls_datalake_role_adf" {
  description = "Role Assingment for ADLS Gen2  storgage."
  type        = string
  default     = "Storage Blob Data Contributor"
}

variable "blob_dataconfig_role_adf" {
  description = "Role Assingment for config bolb storgage."
  type        = string
  default     = "Storage Blob Data Contributor"
}

variable "kv_role_adf" {
  description = "Role assignment for Key Vault."
  type        = string
  default     = "Key Vault Secrets User"
}
