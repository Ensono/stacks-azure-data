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

############################################
# NETWORK INFORMATION
############################################

variable "enable_private_networks" {
  default     = false
  type        = bool
  description = "Enable Private Networking for Secure Data Platform."
}


variable "link_dns_network" {
  description = "weather link DNS with vnets"
  type        = bool
  default     = false
}

variable "network_details" {
  type = map(object({
    name                = string
    address_space       = list(string)
    dns_servers         = list(string)
    resource_group_name = string
    is_hub              = bool
    link_to_private_dns = bool
    subnet_details = map(object({
      sub_name                                      = string
      sub_address_prefix                            = list(string)
      private_endpoint_network_policies_enabled     = bool
      private_link_service_network_policies_enabled = bool
      service_endpoints                             = list(string)
      })
    )

  }))

  default = {
    "amido-stacks-euw-de-hub" = {
      name                = "amido-stacks-euw-de-hub"
      address_space       = ["10.2.0.0/16"]
      dns_servers         = []
      resource_group_name = "amido-stacks-euw-de-hub-network"
      is_hub              = true
      link_to_private_dns = true
      subnet_details = {
        "amido-stacks-euw-de-hub" = {
          sub_name                                      = "amido-stacks-euw-de-hub"
          sub_address_prefix                            = ["10.2.1.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        },
        "build-agent" = {
          sub_name                                      = "build-agent"
          sub_address_prefix                            = ["10.2.2.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        }

    } },


    "amido-stacks-euw-de-nonprod" = {
      name                = "amido-stacks-euw-de-nonprod"
      address_space       = ["10.3.0.0/16"]
      dns_servers         = []
      resource_group_name = "amido-stacks-euw-de-nonprod-network"
      is_hub              = false
      link_to_private_dns = true
      subnet_details = {
        "amido-stacks-euw-de-nonprod-pe" = {
          sub_name                                      = "amido-stacks-euw-de-nonprod-pe"
          sub_address_prefix                            = ["10.3.1.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        },
        "amido-stacks-euw-de-nonprod" = {
          sub_name                                      = "amido-stacks-euw-de-nonprod"
          sub_address_prefix                            = ["10.3.2.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        }
    } },

    "amido-stacks-euw-de-prod" = {
      name                = "amido-stacks-euw-de-prod"
      address_space       = ["10.4.0.0/16"]
      dns_servers         = []
      resource_group_name = "amido-stacks-euw-de-prod-network"
      is_hub              = false
      link_to_private_dns = true
      subnet_details = {
        "amido-stacks-euw-de-prod-pe" = {
          sub_name                                      = "amido-stacks-euw-de-prod-pe"
          sub_address_prefix                            = ["10.4.1.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        },
        "amido-stacks-euw-de-prod" = {
          sub_name                                      = "amido-stacks-euw-de-prod"
          sub_address_prefix                            = ["10.4.2.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        }
    } }
  }
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
