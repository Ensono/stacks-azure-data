locals {

  # Each region must have corresponding a shortend name for resource naming purposes
  location_name_map = {
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

  # Create a list of the networks that need to be created
  # This is a generated mapo using existing values to build up values
  # The reasoning behiund this is that although the networking may change between projects, it will be the same
  # for each run of the terraform so it can be modified here as required
  network_details = {
    "hub_network" = {
      name                = "${var.name_company}-${lookup(local.location_name_map, var.resource_group_location)}-hub"
      address_space       = ["10.16.0.0/16"]
      dns_servers         = []
      resource_group_name = "${var.name_company}-${lookup(local.location_name_map, var.resource_group_location)}-hub-network"
      is_hub              = true
      link_to_private_dns = true
      subnet_details = {
        "subnet-1" = {
          sub_name                                      = "${var.name_company}-de-hub"
          sub_address_prefix                            = ["10.16.1.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints = ["Microsoft.AzureActiveDirectory",
            "Microsoft.KeyVault",
            "Microsoft.ServiceBus",
            "Microsoft.Sql",
          "Microsoft.Storage"]
        },
        "subnet-2" = {
          sub_name                                      = "build-agent"
          sub_address_prefix                            = ["10.16.2.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints = ["Microsoft.AzureActiveDirectory",
            "Microsoft.KeyVault",
            "Microsoft.ServiceBus",
            "Microsoft.Sql",
          "Microsoft.Storage"]
        },
        "subnet-3" = {
          sub_name                                      = "AzureBastionSubnet"
          sub_address_prefix                            = ["10.16.0.0/26"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints = ["Microsoft.AzureActiveDirectory",
            "Microsoft.KeyVault",
            "Microsoft.ServiceBus",
            "Microsoft.Sql",
          "Microsoft.Storage"]
        }
      }
    },

    "nonprod-network" = {
      name                = "${var.name_company}-${lookup(local.location_name_map, var.resource_group_location)}-nonprod"
      address_space       = ["10.17.0.0/16"]
      dns_servers         = []
      resource_group_name = "${var.name_company}-${lookup(local.location_name_map, var.resource_group_location)}-nonprod-network"
      is_hub              = false
      link_to_private_dns = true
      subnet_details = {
        "subnet-1" = {
          sub_name                                      = "${var.name_company}-de-nonprod-pe"
          sub_address_prefix                            = ["10.17.1.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints = ["Microsoft.AzureActiveDirectory",
            "Microsoft.KeyVault",
            "Microsoft.ServiceBus",
            "Microsoft.Sql",
          "Microsoft.Storage"]
        },
        "subnet-2" = {
          sub_name                                      = "${var.name_company}-de-nonprod"
          sub_address_prefix                            = ["10.17.2.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints = ["Microsoft.AzureActiveDirectory",
            "Microsoft.KeyVault",
            "Microsoft.ServiceBus",
            "Microsoft.Sql",
          "Microsoft.Storage"]
        }
      }
    }
    "prod-network" = {
      name                = "${var.name_company}-${lookup(local.location_name_map, var.resource_group_location)}-prod"
      address_space       = ["10.18.0.0/16"]
      dns_servers         = []
      resource_group_name = "${var.name_company}-${lookup(local.location_name_map, var.resource_group_location)}-prod-network"
      is_hub              = false
      link_to_private_dns = true
      subnet_details = {
        "subnet-1" = {
          sub_name                                      = "${var.name_company}-de-prod-pe"
          sub_address_prefix                            = ["10.18.1.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints = ["Microsoft.AzureActiveDirectory",
            "Microsoft.KeyVault",
            "Microsoft.ServiceBus",
            "Microsoft.Sql",
          "Microsoft.Storage"]
        },
        "subnet-2" = {
          sub_name                                      = "${var.name_company}-de-prod"
          sub_address_prefix                            = ["10.18.2.0/24"]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints = ["Microsoft.AzureActiveDirectory",
            "Microsoft.KeyVault",
            "Microsoft.ServiceBus",
            "Microsoft.Sql",
          "Microsoft.Storage"]
        }
      }
    }

  }

  # Get the hub network name which will be used later to deploy the vmss into it
  hub_network_name = [for network in local.network_details : network.name if network.is_hub == true]

}