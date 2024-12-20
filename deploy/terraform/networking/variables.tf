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
  default = "westeurope"
}

variable "is_prod_subscription" {
  type        = bool
  default     = false
  description = "Flag to state if the subscription being deployed to is the production subscription or not. This so that the environments are created properly."
}

variable "environments" {
  type        = list(string)
  default     = ["hub::10.2.0.0/16", "dev:false:10.3.0.0/16", "qa:false:10.4.0.0/16", "uat:true:10.5.0.0/16", "prod:true:10.6.0.0/16"]
  description = "List of environments and networks to create. The format is `name:is_prod_subscription:address_space`"
}

variable "deploy_all_environments" {
  type        = bool
  default     = false
  description = "If true, all environments will be deployed regardless of subscription type, e.g. nonprod or prod"
}

############################################
# NETWORK INFORMATION
############################################

variable "enable_private_networks" {
  default     = false
  type        = bool
  description = "Enable Private Networking for Secure Data Platform."
}


variable "link_dns_network" {
  description = "Should the DNS be linked with the VNETs?"
  type        = bool
  default     = false
}

variable "create_hub_fw" {
  default     = false
  type        = bool
  description = "Determines if the networking modules creates a firewall instance or not."
}

variable "create_fw_public_ip" {
  default     = false
  type        = bool
  description = "Determines if the networking modules creates a firewall IP address or not."
}

variable "create_private_dns_zone" {
  default     = true
  type        = bool
  description = "Determines if the networking modules creates a private dns zone."
}

variable "dns_zone_name" {
  default     = ["privatelink.vaultcore.azure.net", "privatelink.azuredatabricks.net", "privatelink.database.windows.net", "privatelink.blob.core.windows.net", "privatelink.dfs.core.windows.net"]
  description = "The name of the Private DNS Zone. Must be a valid domain name. Changing this forces a new resource to be created."
  type        = list(string)
}

############################################
# VMSS INFORMATION
############################################

variable "vmss_instances" {
  default     = 1
  type        = number
  description = "Sets the default number of VM instances running in the VMSS."
}

variable "vmss_admin_username" {
  default     = "adminuser"
  type        = string
  description = "Sets the admin user name. This is used if remote access is required to a VM instance."
}

variable "vmss_disable_password_auth" {
  default     = false
  type        = bool
  description = "Enables or Disables password authentication. If Password is disabled ssh keys must be provided."
}

variable "vmss_subnet_name" {
  default     = "build-agent"
  type        = string
  description = "The subnet name which the VMSS will be provisioned."
}

variable "build_agent_ip" {
  default     = ""
  description = "IP address of the build agent"
  type        = string
}

############################################
# Azure DevOps Information
############################################

variable "ado_agent_pool_name" {
  type        = string
  description = "Name of the Azure DevOps Agent Pool to which this agent belongs"
  default     = ""
}

variable "ado_create_agent_pool" {
  type        = bool
  default     = false
  description = "If true, an agent pool will be created in Azure DevOps with the necessary information from this Infrastructure"
}

variable "ado_org_url" {
  type        = string
  description = "URL of the Azure DevOps Organization"
}

variable "ado_pat" {
  type        = string
  description = "Personal Access Token for the Azure DevOps Organization"
}

variable "ado_agent_name" {
  type        = string
  description = "Name of the Azure DevOps Agent"
}

variable "ado_project_id" {
  type        = string
  description = "ID of the Azure DevOps Project"
}

variable "ado_create_variable_group" {
  type        = bool
  default     = false
  description = "If true, a variable group will be created in Azure DevOps with the necessary information from this Infrastructure"
}


variable "ado_variable_group_name_prefix" {
  type        = string
  default     = "data-networks"
  description = "Prefix for the name of the Variable Group in Azure DevOps. The suffix is the name of the environment"
}

variable "debug_enabled" {
  type        = bool
  default     = false
  description = "If debug enabled then SSH will be enabled inbound on the NSG"
}

variable "vmss_admin_ssh_key" {
  type        = string
  default     = ""
  description = "SSH Public Key for Admin SSH Access to VMs."
}

