############################################
# RESOURCE INFORMATION
############################################

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
  default     = "uksouth"
}

variable "resource_namer" {
  type        = string
  description = "Caller defined conventional namespace will be used in all resource naming. Where required by the platform special characters will be stripped out and length will be adjusted"
}

variable "azure_object_id" {
  type        = string
  description = "Object ID for SPN"
}

############################################
# STORAGE ACCOUNT SETTINGS
############################################

variable "account_replication_type" {
  type        = string
  description = "The Storage Account replication type. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  default     = "LRS"
}

variable "container_access_type" {
  type        = string
  description = "value"
  default     = "The Access Level configured for this Container. Possible values are blob, container or private. Defaults to private."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow public network access to storage account. Set as true or false."
}

variable "network_rules" {
  type = list(object({
    default_action             = string
    virtual_network_subnet_ids = list(string)
    ip_rules                   = list(string)
    bypass                     = list(string)
  }))
  default     = []
  description = "Network Rules to apply to the storage account."
}

############################################
# NAMING
############################################
variable "resource_tags" {
  description = "Map of tags to be applied to all resources created as part of this module"
  type        = map(string)
  default     = {}
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

variable "storage_account_details" {
  description = "The default value for this variable includes two objects, data_config_storage and data_lake_storage. The data_config_storage object has BlobStorage type, standard tier, and a single config container. The data_lake_storage object has StorageV2 type, standard tier, Hierarchical Namespace enabled, and three containers named curated, staging, and raw. Depending on the value of `hns_enabled` it will create either a Blob storage, or Gen2 Data Lake filesystem, with the names specified in `containers_name`"

  type = map(object({
    account_tier    = string
    account_kind    = string
    name            = string
    hns_enabled     = bool
    containers_name = list(string)
  }))
  default = {
    "data_config_storage" = {
      account_kind    = "StorageV2"
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

variable "enable_private_network" {
  type        = bool
  default     = false
  description = "Determines if the Key Vault will be created as part of the Secure Data Platform."
}

variable "is_manual_connection" {
  type        = bool
  default     = false
  description = "Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource to be created."
}

variable "private_dns_zone_name" {
  type        = string
  default     = ""
  description = "Specifies the Name of the Private DNS Zone Group."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Specifies the list of Private DNS Zones to include within the private_dns_zone_group"
}

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
  default     = ""
  description = "Location of the resource group to provision private endpoint in."
}

variable "blob_private_dns_zone_name" {
  type        = string
  default     = "privatelink.blob.core.windows.net"
  description = "Specifies the Name of the Private DNS Zone Group for blob."
}

variable "blob_dns_resource_group_name" {
  type        = string
  default     = "amido-stacks-euw-de-hub-network"
  description = "Name of the resource group where pvt dns is present for blob."
}

variable "dfs_private_dns_zone_name" {
  type        = string
  default     = "privatelink.dfs.core.windows.net"
  description = "Specifies the Name of the Private DNS Zone Group for blob."
}

variable "dfs_dns_resource_group_name" {
  type        = string
  default     = "amido-stacks-euw-de-hub-network"
  description = "Name of the resource group where pvt dns is present for blob."
}

variable "la_workspace_id" {
  type        = string
  default     = ""
  description = "Log Analytics Workspace ID"
}

variable "dfs_private_zone_id" {
  type        = string
  default     = ""
  description = "Resource ID of the DFS Private DNS Zone"
}

variable "blob_private_zone_id" {
  type        = string
  default     = ""
  description = "Resource ID of the Blob Private DNS Zone"
}
