############################################
# NAMING
############################################

variable "resource_namer" {
  type        = string
  description = "User defined naming convention applied to all resources created as part of this module"
}

variable "resource_tags" {
  description = "Map of tags to be applied to all resources created as part of this module"
  type        = map(string)
  default     = {}
}

variable "name_component" {
  default     = "adf"
  description = "Component Name - should/will be used in conventional resource naming. Typically this will be a logical name for this part of the system i.e. `API` || `middleware` or more generic like `Billing`"
  type        = string
}

variable "tenant_id" {
  type        = string
  default     = ""
  description = "Azure Tenant ID."
}

############################################
# RESOURCE INFORMATION
############################################

variable "resource_group_location" {
  type        = string
  default     = "uksouth"
  description = "Location of Resource group"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group"
}

###########################
# CONDITIONAL SETTINGS
##########################

variable "create_adf" {
  type        = bool
  default     = true
  description = "Set value whether to create a Data Factory or not."
}

###########################
# ADF IDENTITY SETTINGS
##########################

variable "adf_idenity" {
  type        = bool
  default     = true
  description = "Enable identity block in module."
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "Specifies the type of Managed Service Identity that should be configured on this Data Factory. Possible values are SystemAssigned, UserAssigned, SystemAssigned,UserAssigned (to enable both)."
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Data Factory."
}


###########################
# ADF SETTINGS
##########################

variable "public_network_enabled" {
  type        = bool
  default     = true
  description = "Is the Data Factory visible to the public network? Defaults to true"
}

variable "managed_virtual_network_enabled" {
  type        = bool
  default     = false
  description = "Is Managed Virtual Network enabled?"
}

variable "adf_managed-vnet-runtime_name" {
  type        = string
  default     = "adf-managed-vnet-runtime"
  description = "Specifies the name of the Managed Integration Runtime. Changing this forces a new resource to be created. Must be globally unique. See the Microsoft documentation for all restrictions."
}

variable "runtime_virtual_network_enabled" {
  type        = bool
  default     = true
  description = "Is Integration Runtime compute provisioned within Managed Virtual Network? Changing this forces a new resource to be created."
}

variable "la_workspace_id" {
  type        = string
  default     = ""
  description = "Log Analytics Workspace ID"
}

variable "ir_enable_interactive_authoring" {
  type        = bool
  default     = true
  description = "Test IR"
}

###########################
# Global parameter  for ADF SETTINGS
##########################


variable "global_parameter" {
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  description = "Specifies whether to add global parameters to ADF"
  default = [{
    name  = "environment"
    type  = "String"
    value = "nonprod"
    }
  ]
}
###########################
# ADF GIT INTEGRATION SETTINGS
##########################
variable "git_integration" {
  type        = string
  default     = "null"
  description = "Integrate a git repository with ADF. Can be null, github or vsts (use vsts for Azure DevOps Repos)."
  validation {
    condition     = can(regex("^null$|^github$|^vsts$", var.git_integration))
    error_message = "Err: git integration value is not valid - it can be null, github, vsts."
  }
}


variable "repository_name" {
  type        = string
  default     = "stacks-data-infrastructure"
  description = "Specifies the name of the git repository."
}
variable "branch_name" {
  type        = string
  default     = "main"
  description = "Specifies repository branch to use as the collaboration branch."
}


variable "root_folder" {
  type        = string
  default     = "/adf_managed"
  description = "Specifies the root folder within the repository. Set to / for the top level."
}


###########################
# ADF GITHUB SETTINGS
##########################
variable "github_account_name" {
  type        = string
  default     = "amido"
  description = "Specifies the GitHub account name."
}


variable "github_url" {
  type        = string
  default     = "https://github.com"
  description = "Specifies the GitHub Enterprise host name. For example: https://github.mydomain.com. Use https://github.com for open source repositories."
}


###########################
# ADF VSTS SETTINGS
##########################
variable "vsts_account_name" {
  type        = string
  default     = "amido"
  description = "Specifies the VSTS / Azure DevOps account name."
}


variable "vsts_project_name" {
  type        = string
  default     = "amido-stacks"
  description = "Specifies the name of the VSTS / Azure DevOps project."
}
