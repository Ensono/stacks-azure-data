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

variable "adls_storage_account_name" {
  type        = string
  description = "ADLS Storage Account Name"
}

variable "default_storage_account_name" {
  type        = string
  description = "Default Storage Account Name"
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
  default     = "stacks-data-core"
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
