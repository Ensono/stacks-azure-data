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

variable "databricks_sku" {
  type        = string
  default     = "premium"
  description = "The SKU to use for the databricks instance"

  validation {
    condition     = can(regex("standard|premium|trial", var.databricks_sku))
    error_message = "Err: Valid options are 'standard', 'premium' or 'trial'."
  }
}


############################################
# Resource Diagnostic Setting 
############################################

variable "enable_databricksws_diagnostic" {
  type        = bool
  description = "Whether to enable diagnostic settings for the Azure Databricks workspace"
  default     = false
}

variable "databricksws_diagnostic_setting_name" {
  type        = string
  default     = "Databricks to Log Analytics"
  description = "The Databricks workspace diagnostic setting name."
}

variable "data_platform_log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The Log Analytics Workspace used for the whole Data Platform."
}

############################################
# Resource Databricks workspace setting 
############################################

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Enables or Disabled Public Access to Databricks Workspace."
}

variable "network_security_group_rules_required" {
  type        = string
  default     = "NoAzureDatabricksRules"
  description = " Does the data plane (clusters) to control plane communication happen over private link endpoint only or publicly? Possible values AllRules, NoAzureDatabricksRules or NoAzureServiceRules."
}

variable "enable_private_network" {
  type        = bool
  default     = false
  description = "Enable Secure Data Platform."
}

variable "nat_idle_timeout" {
  type        = number
  default     = 10
  description = "Idle timeout period in minutes."
}

variable "browser_authentication_enabled" {
  type        = bool
  default     = false
  description = "Specify wether to create to private endpoint for browser authentication, False in Dev and True in Production should be enable in on enviroment."
}

############################################
# Network Details
############################################

variable "create_pe_subnet" {
  type        = bool
  default     = false
  description = "Set to true if you need the module to create the private endpoint subnet."
}

variable "create_db_dns_zone" {
  type        = bool
  default     = true
  description = "Create DNS Zone for Azure Databricks."
}

variable "db_dns_zone_rg" {
  type        = string
  default     = "value"
  description = "Resource Group where DNS is created."
}

variable "vnet_name" {
  type        = string
  default     = ""
  description = "Name of the VNET inwhich the Databricks Workspace will be provisioned."
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

variable "vnet_address_prefix" {
  type        = string
  default     = ""
  description = "Address Prefix of the VNET."
}

variable "dns_record_ttl" {
  type        = number
  default     = 300
  description = "TTL for DNS Record."
}

variable "service_endpoints" {
  type        = list(string)
  default     = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
  description = "List of Service Endpoints Enabled on the Subnet."
}

variable "create_nat" {
  type        = bool
  default     = false
  description = "Deploy Databricks with a NAT Gateway."
}

variable "create_lb" {
  type        = bool
  default     = false
  description = "Deploy Databricks with a Load Balancer."
}

variable "managed_vnet" {
  type        = bool
  default     = false
  description = "Used to determine if Databricks is created in a managed vnet configuration."
}

variable "create_pip" {
  type        = bool
  default     = false
  description = "Create Databricks with a Public IP."
}

variable "private_dns_zone_name" {
  type        = string
  default     = "privatelink.azuredatabricks.net"
  description = "Specifies the Name of the Private DNS Zone Group."
}

variable "dns_resource_group_name" {
  type        = string
  default     = "amido-stacks-euw-de-hub-network"
  description = "Name of the resource group where pvt dns is present."
}

variable "private_dns_zone_id" {
  type        = string
  default     = ""
  description = "Specifies the ID of the Private DNS Zone Group."
}

variable "virtual_network_id" {
  type        = string
  default     = ""
  description = "Virtual Network Resource ID."
}

variable "public_subnet_id" {
  type        = string
  default     = ""
  description = "Public Subnet Resource ID."
}

variable "private_subnet_id" {
  type        = string
  default     = ""
  description = "Private Subnet Resource ID."
}

variable "pe_subnet_id" {
  type        = string
  default     = ""
  description = "Private Endpoint Subnet Resource ID."
}

variable "adf_private_nsg_subnet_association_id" {
  type    = string
  default = ""
}

variable "adf_public_nsg_subnet_association_id" {
  type    = string
  default = ""
}

variable "nat_gateway_id" {
  type    = string
  default = ""
}

variable "nat_gateway_pip_id" {
  type    = string
  default = ""
}
