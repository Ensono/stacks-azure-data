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



############################################
# NETWORK INFORMATION
############################################

variable "enable_private_networks" {
  default     = true
  type        = bool
  description = "Enable Private Networking for Secure Data Platform."
}

variable "link_dns_network" {
  description = "git addShould the DNS be linked with the VNETs?"
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


############################################
# VMSS INFORMATION
############################################

variable "vmss_instances" {
  default     = 2
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