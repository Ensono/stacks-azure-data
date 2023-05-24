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

variable "repository_name" {
  type        = string
  default     = "stacks-azure-data-ingest"
  description = "Specifies the name of the git repository."
}

variable "root_folder" {
  type        = string
  default     = "/data_factory/adf_managed"
  description = "Specifies the root folder within the repository. Set to / for the top level."
}

variable "name_pe_blob" {
  type        = string
  default     = "private-config-blob"
  description = "Specifies the name for Private endpoint for blob."
}

variable "name_pe_dfs" {
  type        = string
  default     = "private-config-blob"
  description = "Specifies the name for Private endpoint for Adls container."
}

variable "name_pe_kv" {
  type        = string
  default     = "private-config-blob"
  description = "Specifies the name for Private endpoint for Azure Key vault."
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

variable "adb_role_adf" {
  description = "Role assignment for Azure databricks."
  type        = string
  default     = "Contributor"
}

variable "e_2_test_role" {
  description = "Role assignment for end to end Testing."
  type        = string
  default     = "Storage Blob Data Contributor"
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
  description = "A list of Azure Active Directory user, group or application object IDs that will have contributor role for  the Key Vault."
  type        = list(string)
  default     = []
}

############################################
# SQL INFORMATION
############################################

variable "sql_version" {
  type        = string
  default     = "12.0"
  description = "The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). Changing this forces a new resource to be created."
}

variable "administrator_login" {
  type        = string
  sensitive   = true
  description = "The administrator login name for the new server. Required unless azuread_authentication_only in the azuread_administrator block is true. When omitted, Azure will generate a default username which cannot be subsequently changed. Changing this forces a new resource to be created."
}

variable "azuread_administrator" {
  type = list(object({
    login_username = string
    object_id      = string
  }))
  description = "Specifies whether only AD Users and administrators (like azuread_administrator.0.login_username) can be used to login, or also local database users (like administrator_login). When true, the administrator_login and administrator_login_password properties can be omitted."
  default     = []

}

variable "sql_db_names" {
  type        = list(string)
  default     = ["sqldbtest"]
  description = "The name of the MS SQL Database. Changing this forces a new resource to be created."
}

variable "sql_password" {
  type        = string
  default     = "sql-password"
  description = "Name of the Key for Sql admin Password, its not the actual value/password but the by the name its referred to."
}

############################################
# DATABRICKS INFORMATION
############################################

variable "databricks_sku" {
  type        = string
  default     = "premium"
  description = "The SKU to use for the databricks instance"

  validation {
    condition     = can(regex("standard|premium|trial", var.databricks_sku))
    error_message = "Err: Valid options are 'standard', 'premium' or 'trial'."
  }
}

variable "enable_databricksws_diagnostic" {
  type        = bool
  description = "Whether to enable diagnostic settings for the Azure Databricks workspace"
  default     = true
}

variable "databricksws_diagnostic_setting_name" {
  type        = string
  default     = "Databricks to Log Analytics"
  description = "The Databricks workspace diagnostic setting name."
}

variable "enable_enableDbfsFileBrowser" {
  type        = bool
  description = "Whether to enable Dbfs File browser for the Azure Databricks workspace"
  default     = false
}

variable "add_rbac_users" {
  description = "If set to true, the module will create databricks users and  group named 'project_users' with the specified users as members, and grant workspace and SQL access to this group. Default is false."
  type        = bool
  default     = true
}

variable "rbac_databricks_users" {
  type = map(object({
    display_name = string
    user_name    = string
    active       = bool
  }))
  description = "If 'add_rbac_users' set to true then specifies RBAC Databricks users"
  default = {
    MehdiKimakhe = {
      display_name = "Mehdi Kimakhe"
      user_name    = "mehdi.kimakhe@amido.com"
      active       = true
    }
    LorraineSnaddon = {
      display_name = "Lorraine Snaddon"
      user_name    = "lorraine.snaddon@amido.com"
      active       = true
    }
  }
}

variable "databricks_group_display_name" {
  type        = string
  description = "If 'add_rbac_users' set to true then specifies databricks group display name"
  default     = "project_users"
}
