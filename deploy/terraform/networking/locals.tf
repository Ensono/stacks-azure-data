locals {

  # Create a local object for the environments that states the network range etc
  # This is determined from the environments variable. Each string is split using a `:` to give the name,
  # if it should be deployed in the production subscription and the network range
  # This is used to determine the networks that are to be created and the subnets within them
  environments_all = { for env_definition in var.environments :
    "${split(":", env_definition)[0]}" => {
      is_prod       = split(":", env_definition)[1] == "true" ? true : false
      address_space = split(":", env_definition)[2]
    }
  }

  # Determine if this is a production subscription or the override is being used
  is_prod_subscription = contains(["prod"], data.azurerm_subscription.current.tags) || var.is_prod_subscription
  deploy_all_envs      = contains(["override"], data.azurerm_subscription.current.tags) || var.deploy_all_environments

  # Create a list of envs that are to be created, based on the is_prod_subscription variable
  environments = { for name, env in local.environments_all :
    name => {
      address_space = env.address_space
    } if env.is_prod == local.is_prod_subscription || name == "hub" || local.deploy_all_envs
  }

  # Each region must have corresponding a shortened name for resource naming purposes
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

  # determine the name of the agent pool, if it has not been provided
  ado_agent_pool_name = var.ado_agent_pool_name == "" ? "${module.label_hub.id}-agent-pool" : var.ado_agent_pool_name

  # determine the prefix for the ado variable group
  # this is so that it is easy to identify in the Azure DevOps UI and cannot be confused with other projects
  # using this template
  tf_stage           = lower(data.external.env.result["STAGE"])
  ado_vg_name_prefix = "${var.name_company}-${var.name_project}-${var.name_component}-${local.tf_stage}"

  # Create the network details list
  # -- HUB Network
  hub_network = [
    {

      name                = "${module.label_hub.id}"
      environment         = "hub"
      address_space       = [local.environments["hub"].address_space]
      dns_servers         = []
      resource_group_name = "${module.label_hub.id}"
      is_hub              = true
      is_adf_network      = false
      link_to_private_dns = true
      subnet_details = [
        {
          sub_name                                      = "${module.label_hub.id}"
          sub_address_prefix                            = [cidrsubnet(local.environments["hub"].address_space, 8, 1)]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
          is_pe_subnet                                  = false
          is_prod                                       = false
          is_adf_private_subnet                         = false
          is_adf_public_subnet                          = false
        },
        {
          sub_name                                      = "build-agent"
          sub_address_prefix                            = [cidrsubnet(local.environments["hub"].address_space, 8, 2)]
          private_endpoint_network_policies_enabled     = true
          private_link_service_network_policies_enabled = true
          service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
          is_pe_subnet                                  = false
          is_prod                                       = false
          is_adf_private_subnet                         = false
          is_adf_public_subnet                          = false
        }
      ]
    }
  ]

  env_networks = [for name, env in local.environments : {
    name                = "${module.label_default.id}-${name}"
    environment         = name
    address_space       = [env.address_space]
    dns_servers         = []
    resource_group_name = "${module.label_default.id}-${name}-network"
    is_hub              = false
    is_adf_network      = true
    link_to_private_dns = true
    subnet_details = [
      {
        sub_name                                      = "${module.label_default.id}-${name}-pe"
        sub_address_prefix                            = [cidrsubnet(env.address_space, 8, 1)]
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
        service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        is_pe_subnet                                  = true
        is_prod                                       = false
        is_adf_private_subnet                         = false
        is_adf_public_subnet                          = false
      },
      {
        sub_name                                      = "${module.label_default.id}-${name}"
        sub_address_prefix                            = [cidrsubnet(env.address_space, 8, 2)]
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
        service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        is_pe_subnet                                  = false
        is_prod                                       = false
        is_adf_private_subnet                         = false
        is_adf_public_subnet                          = false
      },
      {
        sub_name                                      = "${module.label_default.id}-${name}-adf-priv"
        sub_address_prefix                            = [cidrsubnet(env.address_space, 8, 3)]
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
        service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        is_pe_subnet                                  = false
        is_prod                                       = false
        is_adf_private_subnet                         = true
        is_adf_public_subnet                          = false
      },
      {
        sub_name                                      = "${module.label_default.id}-${name}-adf-pub"
        sub_address_prefix                            = [cidrsubnet(env.address_space, 8, 4)]
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
        service_endpoints                             = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
        is_pe_subnet                                  = false
        is_prod                                       = false
        is_adf_private_subnet                         = false
        is_adf_public_subnet                          = true
      }
    ]
  } if name != "hub"]

  # Create the network details list
  network_details = concat(local.hub_network, local.env_networks)

  # Get the hub network name which will be used later to deploy the vmss into it
  hub_network_name = [for network in local.network_details : network.name if network.is_hub == true][0]

  # Get the Private Endpoint subnets from teh network_details
  # There will be several, one for each environment so need to create an object for each one
  pe_subnets = flatten(
    [
      for network_info in local.network_details : [
        for subnet_info in network_info.subnet_details : {
          subnet_name           = subnet_info.sub_name
          subnet_address_prefix = subnet_info.sub_address_prefix
          environment           = network_info.environment
          resource_group        = network_info.resource_group_name
          vnet_name             = network_info.name
        } if subnet_info.is_pe_subnet == true
      ]
    ]
  )

  # Determine the private endpoint subnets for each environment
  public_subnets = flatten(
    [
      for network_info in local.network_details : [
        for subnet_info in network_info.subnet_details : {
          name        = subnet_info.sub_name
          prefix      = subnet_info.sub_address_prefix
          environment = network_info.environment
        } if subnet_info.is_adf_public_subnet == true
      ]
    ]
  )

  private_subnets = flatten(
    [
      for network_info in local.network_details : [
        for subnet_info in network_info.subnet_details : {
          name        = subnet_info.sub_name
          prefix      = subnet_info.sub_address_prefix
          environment = network_info.environment
        } if subnet_info.is_adf_private_subnet == true
      ]
    ]
  )

  # Create the object that will be used to populate the variable groups
  # and the environment variables file
  outputs = { for envname, detail in local.environments : envname => {
    name_company                          = var.name_company
    dns_zone_resource_group_name          = module.networking[0].vnets[local.hub_network_name].vnet_resource_group_name
    pe_subnet_id                          = [for name, detail in module.networking[0].private_endpoint_subnets : detail.subnet_id if name == envname][0]
    pe_subnet_name                        = [for pe_subnet in local.pe_subnets : pe_subnet.subnet_name if pe_subnet.environment == envname][0]
    pe_subnet_prefix                      = [for pe_subnet in local.pe_subnets : jsonencode(pe_subnet.subnet_address_prefix) if pe_subnet.environment == envname][0]
    vnet_name                             = [for pe_subnet in local.pe_subnets : pe_subnet.vnet_name if pe_subnet.environment == envname][0]
    vnet_resource_group_name              = [for pe_subnet in local.pe_subnets : pe_subnet.resource_group if pe_subnet.environment == envname][0]
    nat_gateway_id                        = [for env, id in module.networking[0].nat_gateway_ids : id if env == envname][0]
    nat_gateway_pip_id                    = [for env, id in module.networking[0].nat_public_ip_ids : id if env == envname][0]
    public_subnet_name                    = [for subnet in local.public_subnets : subnet.name if subnet.environment == envname][0]
    public_subnet_prefix                  = [for subnet in local.public_subnets : jsonencode(subnet.prefix) if subnet.environment == envname][0]
    private_subnet_name                   = [for subnet in local.private_subnets : subnet.name if subnet.environment == envname][0]
    private_subnet_prefix                 = [for subnet in local.private_subnets : jsonencode(subnet.prefix) if subnet.environment == envname][0]
    adf_private_nsg_subnet_association_id = [for name, detail in module.networking[0].nsg_subnet_associations : detail.private if name == envname][0]
    adf_public_nsg_subnet_association_id  = [for name, detail in module.networking[0].nsg_subnet_associations : detail.public if name == envname][0]
  } if envname != "hub" && var.enable_private_networks }

  # Create a local object for the template mapping so that the script files can be generated
  templates = flatten([
    for file in ["envvars.bash.tpl", "envvars.ps1.tpl", "inputs.tfvars.tpl"] : [
      for name, detail in local.environments : {
        envname  = name
        file     = file
        items    = local.outputs[name]
        template = "${path.module}/templates/${file}"
      } if name != "hub"
    ]
  ])

}

