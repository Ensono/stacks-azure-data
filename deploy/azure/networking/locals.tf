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

  network_details = {
        "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-hub" = {
            name                = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-hub"
            address_space       = ["10.2.0.0/16"]
            dns_servers         = []
            resource_group_name = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-hub-network"
            is_hub              = true
            link_to_private_dns = true
            subnet_details = {
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-hub" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-hub"
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
            }
        },

        "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-nonprod" = {
            name                = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-nonprod"
            address_space       = ["10.3.0.0/16"]
            dns_servers         = []
            resource_group_name = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-nonprod-network"
            is_hub              = false
            link_to_private_dns = true
            subnet_details = {
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-nonprod-pe" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-nonprod-pe"
                sub_address_prefix                            = ["10.3.1.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                },
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-nonprod" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-nonprod"
                sub_address_prefix                            = ["10.3.2.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                }
            } 
        },

        "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-prod" = {
            name                = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-prod"
            address_space       = ["10.4.0.0/16"]
            dns_servers         = []
            resource_group_name = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-prod-network"
            is_hub              = false
            link_to_private_dns = true
            subnet_details = {
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-prod-pe" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-prod-pe"
                sub_address_prefix                            = ["10.4.1.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                },
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-prod" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-prod"
                sub_address_prefix                            = ["10.4.2.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                }
            }
        },

        "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-nonprod" = {
            name                = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-nonprod"
            address_space       = ["10.5.0.0/16"]
            dns_servers         = []
            resource_group_name = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-nonprod-network"
            is_hub              = false
            link_to_private_dns = true
            subnet_details = {
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-nonprod-pe" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-nonprod-pe"
                sub_address_prefix                            = ["10.5.1.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                },
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-nonprod" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-nonprod"
                sub_address_prefix                            = ["10.5.2.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                }
            } 
        },

        "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-prod" = {
            name                = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-prod"
            address_space       = ["10.6.0.0/16"]
            dns_servers         = []
            resource_group_name = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-prod-network"
            is_hub              = false
            link_to_private_dns = true
            subnet_details = {
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-prod-pe" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-prod-pe"
                sub_address_prefix                            = ["10.6.1.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                },
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-prod" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-qa-prod"
                sub_address_prefix                            = ["10.6.2.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                }
            }
        },

        "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-test-nonprod" = {
            name                = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-test-nonprod"
            address_space       = ["10.7.0.0/16"]
            dns_servers         = []
            resource_group_name = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-test-nonprod-network"
            is_hub              = false
            link_to_private_dns = true
            subnet_details = {
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-test-nonprod-pe" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-test-nonprod-pe"
                sub_address_prefix                            = ["10.7.1.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                },
                "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-test-nonprod" = {
                sub_name                                      = "${var.name_company}-${var.name_project}-${lookup(local.location_name_map, var.resource_group_location)}-de-test-nonprod"
                sub_address_prefix                            = ["10.7.2.0/24"]
                private_endpoint_network_policies_enabled     = true
                private_link_service_network_policies_enabled = true
                service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
                }
            }
        }
    }
}
