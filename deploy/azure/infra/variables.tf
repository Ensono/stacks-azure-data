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

variable "managed_virtual_network_enabled" {
  type        = bool
  default     = true
  description = "Is Managed Virtual Network enabled?"
}


variable "adf_managed-vnet-runtime_name" {
  type        = string
  default     = "adf-managed-vnet-runtime"
  description = "Specifies the name of the Managed Integration Runtime. Changing this forces a new resource to be created. Must be globally unique. See the Microsoft documentation for all restrictions."
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
  default     = "private-dfs"
  description = "Specifies the name for Private endpoint for Adls container."
}

variable "name_pe_kv" {
  type        = string
  default     = "private-kv"
  description = "Specifies the name for Private endpoint for Azure Key vault."
}

variable "name_pe_sql" {
  type        = string
  default     = "private-config-sql"
  description = "Specifies the name for Private endpoint for Azure Sql Server."
}

variable "name_pe_db" {
  type        = string
  default     = "private-databricks"
  description = "Specifies the name for Private endpoint for Azure Databricks."

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

variable "sql_role_adf" {
  description = "Role assignment for Sql Server."
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

variable "azure_client_secret" {
  type        = string
  description = "A client secret that was generated for the App Registration."
  sensitive   = true
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

variable "databricks_enableDbfsFileBrowser" {
  type        = bool
  description = "Whether to enable Dbfs File browser for the Azure Databricks workspace"
  default     = true
}

variable "public_network_access_enabled" {
  description = "If set to true, User will be able to access databrick workspace  UI from Azure portal, this should set to false in production."
  type        = bool
  default     = true
}

variable "databricks-host" {
  type        = string
  default     = "databricks-host"
  description = "Name of the Key for databricks host, its not the actual value/password but the by the name its referred to."
}

variable "databricks-token" {
  type        = string
  default     = "databricks-token"
  description = "Name of the Key for databricks token, its not the actual value/password but the by the name its referred to."
}

variable "databricks_secret_scope_kv" {
  type        = string
  default     = "key-vault-backed"
  description = "Name of the databricks secret scope for Key vault."
}

variable "databricks_pat_comment" {
  type        = string
  default     = "Terraform Provisioning"
  description = "Comment for databricks PAT"
}

variable "vnet_resource_group" {
  type        = string
  default     = ""
  description = "The Resource Group which the VNET is provisioned."
}

variable "public_subnet_name" {
  type        = string
  default     = ""
  description = "Name of the Public Databricks Subnet."
}

variable "private_subnet_name" {
  type        = string
  default     = ""
  description = "Name of the Private Databricks Subnet."
}

variable "public_subnet_prefix" {
  type        = list(string)
  default     = []
  description = "IP Address Space fo the Public Databricks Subnet."
}

variable "private_subnet_prefix" {
  type        = list(string)
  default     = []
  description = "IP Address Space fo the Private Databricks Subnet."

}

variable "pe_subnet_prefix" {
  type        = list(string)
  default     = []
  description = "IP Address Space fo the Private Endpoints Databricks Subnet."

}

variable "pe_subnet_name" {
  type        = string
  default     = ""
  description = "Name of the Subnet used to provision Private Endpoints into."
}

variable "browser_authentication_enabled" {
  type        = bool
  default     = false
  description = "Specify wether to create to private endpoint for browser authentication, False in Dev and True in Production should be enable in on enviroment."
}


############################################
# NETWORK INFORMATION
############################################

variable "enable_private_networks" {
  default     = true
  type        = bool
  description = "Enable Private Networking for Secure Data Platform."
}

variable "subnet_name" {
  type        = string
  default     = ""
  description = "The name of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint"
}

variable "vnet_name" {
  type        = string
  default     = ""
  description = "The VNET in which the Subnet resides."
}

variable "vnet_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the resource group for the vnet which the subnet resides."
}

variable "dns_zone_name" {
  default     = ["privatelink.vaultcore.azure.net", "privatelink.azuredatabricks.net", "privatelink.database.windows.net", "privatelink.blob.core.windows.net", "privatelink.dfs.core.windows.net"]
  description = "The name of the Private DNS Zone. Must be a valid domain name. Changing this forces a new resource to be created."
  type        = list(string)
}

variable "dfs_private_zone" {
  type        = string
  default     = "privatelink.dfs.core.windows.net"
  description = "Resource ID of the DFS Private DNS Zone"
}

variable "blob_private_zone" {
  type        = string
  default     = "privatelink.blob.core.windows.net"
  description = "Resource ID of the Blob Private DNS Zone"
}

variable "kv_private_zone" {
  type        = string
  default     = "privatelink.vaultcore.azure.net"
  description = "Resource ID of the KV Private DNS Zone"
}

variable "sql_private_zone" {
  type        = string
  default     = "privatelink.database.windows.net"
  description = "Resource ID of the Sql Private DNS Zone"
}

variable "adb_private_zone" {
  type        = string
  default     = "privatelink.azuredatabricks.net"
  description = "Resource ID of the ADB Private DNS Zone"
}

variable "link_dns_spoke_network" {
  type        = bool
  default     = false
  description = "link DNS zones to network"
}


############################################
# PRIVATE ENDPOINT INFORMATION
############################################

variable "pe_subnet_id" {
  type        = string
  default     = ""
  description = "ID for the Private Endpoint Subnet"
}

variable "pe_resource_group_name" {
  type        = string
  default     = ""
  description = "Name of the resource group to provision private endpoint in."
}

variable "pe_resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group to provision private endpoint in."
}
variable "dns_zone_resource_group_name" {
  type        = string
  default     = ""
  description = "Name of the resource group where pvt dns is present."
}

variable "blob_private_dns_zone_name" {
  type        = string
  default     = "privatelink.blob.core.windows.net"
  description = "Specifies the Name of the Private DNS Zone Group for blob."
}

variable "dfs_private_dns_zone_name" {
  type        = string
  default     = "privatelink.dfs.core.windows.net"
  description = "Specifies the Name of the Private DNS Zone Group for blob."
}

############################################
# PUBLIC NETWORK ACCESS INFORMATION
############################################

variable "kv_public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Allow public network access to Key Vault. Set as true or false."
}

variable "sa_public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Allow public network access to storage account. Set as true or false."
}

variable "sql_public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Allow public network access to sql server. Set as true or false."
}

variable "adb_databricks_hosturl" {
  type    = string
  default = ""
}

variable "adb_databricks_id" {
  type    = string
  default = ""
}
