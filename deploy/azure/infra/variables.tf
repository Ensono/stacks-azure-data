############################################
# AUTHENTICATION
############################################
# RELYING PURELY ON ENVIRONMENT VARIABLES as the user can control these from their own environment
############################################
# NAMING
############################################

variable "name_company" {
  type = string
}

variable "name_project" {
  type = string
}

variable "name_component" {
  type = string
}

variable "name_domain" {
  type = string
}

variable "stage" {
  type = string
}

variable "attributes" {
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
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

############################################
# AZURE INFORMATION
############################################

variable "resource_group_location" {
  type = string
}

variable "data_factory_name" {
  type        = string
  description = "Data Factory Name"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "adls_storage_account_name" {
  type        = string
  description = "ADLS Storage Account Name"
}

variable "default_storage_account_name" {
  type        = string
  description = "Default Storage Account Name"
}

variable "platform_scope" {
  type        = string
  description = "Platform Scope"
}

variable "adls_account_replication_type" {
  type        = string
  description = "The ADLS Storage Account replication type"
  default     = "LRS"
}

variable "adls_containers" {
  type        = set(string)
  description = "ADLS containers to create"
  default     = ["dev"]
}

variable "application_insights_daily_data_cap_in_gb" {
  type        = number
  description = "The daily cap in ingesting data, once reached no more data will be ingested for the period."
  default     = 5
}

variable "application_insights_daily_data_cap_notifications_disabled" {
  type        = bool
  description = "Enables or disables the daily cap notification."
  default     = true
}

variable "application_insights_retention_in_days" {
  type        = number
  description = "Number of days data is retained for - this only applies to the classic resource."
  default     = 30
}
###########################
# Core infrastructure settings
##########################
variable "core_environment" {
  type        = string
  description = "Name of the environment for the core infrastructure"
  default     = "nonprod"
}

variable "tfstate_key" {
  type        = string
  description = "Name of the key in remote storage for the core environmnent"
  default     = "core-sharedservicesenv"
}

variable "tfstate_storage_account" {
  type        = string
  description = "Name of the storage account that holds the Terraform state"
  default     = "amidostackstfstate"
}

variable "tfstate_container_name" {
  type        = string
  description = "Name of the container in the specified storage account holding the state"
  default     = "tfstate"
}

variable "tfstate_resource_group_name" {
  type        = string
  description = "Name of the resource group that holds the the above resources"
  default     = "Stacks-Ancillary-Resources"
}
