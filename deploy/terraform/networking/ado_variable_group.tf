# This resource runs once all the resources have been deployed
#
# It takes all of the outputs and puts them into the named resource group 
# in Azure DevOps

# NOTE: If the variable group is updated manually and this resource is run again
# the manual items will be lost

resource "azuredevops_variable_group" "ado_vg" {

  for_each = var.enable_private_networks && var.ado_create_variable_group ? {
    for name, detail in local.environments : name => detail if name != "hub"
  } : {}

  project_id   = data.azuredevops_project.ado[0].id
  name         = "${var.ado_variable_group_name_prefix}-${each.key}"
  description  = "Azure resource names from the Network deployment for the ${each.key} environment. Do not update this group manually as it is managed by Terraform"
  allow_access = true

  # Get the name of the dns_zone_resource_group
  variable {
    name  = "dns_zone_resource_group"
    value = module.networking[0].vnets[local.hub_network_name].vnet_resource_group_name
  }

  # Create the entries for the private endpoints for this environment
  variable {
    name  = "pe_subnet_name"
    value = [for pe_subnet in local.pe_subnets : pe_subnet.subnet_name if pe_subnet.environment == each.key][0]
  }

  variable {
    name  = "pe_subnet_prefix"
    value = [for pe_subnet in local.pe_subnets : jsonencode(pe_subnet.subnet_address_prefix) if pe_subnet.environment == each.key][0]
  }

  variable {
    name  = "vnet_name"
    value = [for pe_subnet in local.pe_subnets : pe_subnet.vnet_name if pe_subnet.environment == each.key][0]
  }

  variable {
    name  = "vnet_resource_group_name"
    value = [for pe_subnet in local.pe_subnets : pe_subnet.resource_group if pe_subnet.environment == each.key][0]
  }

  # Set the private subnet details
  variable {
    name  = "public_subnet_name"
    value = [for subnet in local.public_subnets : subnet.name if subnet.environment == each.key][0]
  }

  variable {
    name  = "public_subnet_prefix"
    value = [for subnet in local.public_subnets : jsonencode(subnet.prefix) if subnet.environment == each.key][0]
  }

  variable {
    name  = "private_subnet_name"
    value = [for subnet in local.private_subnets : subnet.name if subnet.environment == each.key][0]
  }

  variable {
    name  = "private_subnet_prefix"
    value = [for subnet in local.private_subnets : jsonencode(subnet.prefix) if subnet.environment == each.key][0]
  }

}
