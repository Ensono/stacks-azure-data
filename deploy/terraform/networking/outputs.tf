
output "environments" {
  value = local.environments
}

output "dns_zone_resource_group" {
  value       = module.networking[0].vnets[local.hub_network_name].vnet_resource_group_name
  description = "Name of the resource group where all the DNS zone resources are created"
}

# output "private_endpoint_subnets" {
#   value = local.pe_subnets
# }

# output "private_subnet_ids" {
#   value = module.networking[0].private_subnet_ids
# }

output "private_endpoint_subnets" {
  value = module.networking[0].private_endpoint_subnets
}

output "nsg_subnet_associations" {
  value = module.networking[0].nsg_subnet_associations
}

output "nat_subnet_associations" {
  value = module.networking[0].nat_subnet_associations
}
output "public_subnets" {
  value = local.public_subnets
}

output "private_subnets" {
  value = local.private_subnets
}

output "subnets" {
  value = module.networking[0].subnets
}

output "ado_agent_pool_name" {
  value = local.ado_agent_pool_name
}

output "outputs" {
  value       = local.outputs
  description = "JSON encoded respresentation of the outputs that have been created in the ADO variable groups (if specified) and the script files"
}
