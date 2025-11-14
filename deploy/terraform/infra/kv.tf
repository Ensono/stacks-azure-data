# KV for ADF

# Public access has to be enabled to allow access from virtual networks

module "kv_default" {
  # source                        = "git::https://github.com/ensono/stacks-terraform//azurerm/modules/azurerm-kv?ref=v3.0.13"
  source                        = "github.com/ensono/terraform-azurerm-kv"
  resource_namer                = module.default_label_short.id
  resource_group_name           = azurerm_resource_group.default.name
  resource_group_location       = azurerm_resource_group.default.location
  create_kv_networkacl          = true
  enable_rbac_authorization     = false
  resource_tags                 = module.default_label_short.tags
  contributor_object_ids        = concat(var.contributor_object_ids, [data.azurerm_client_config.current.object_id])
  enable_private_network        = var.enable_private_networks
  pe_subnet_id                  = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].id) : ""
  pe_resource_group_name        = var.enable_private_networks ? tostring(data.azurerm_subnet.pe_subnet[0].resource_group_name) : ""
  pe_resource_group_location    = var.pe_resource_group_location
  dns_resource_group_name       = local.dns_zone_resource_group_name
  public_network_access_enabled = var.enable_private_networks ? var.kv_public_network_access_enabled : true # enabled if only public network otherwise cannot connect
  kv_private_dns_zone_id        = var.enable_private_networks ? tostring(data.azurerm_private_dns_zone.kv_private_dns_zone[0].id) : ""
  virtual_network_subnet_ids    = var.enable_private_networks ? [tostring(data.azurerm_subnet.pe_subnet[0].id), tostring(data.azurerm_subnet.build_agent_subnet[0].id)] : []
  network_acl_default_action    = var.enable_private_networks ? "Deny" : "Allow"
  network_acls_bypass           = "AzureServices" # Allow Azure trusted services (e.g., Azure Pipelines) to bypass firewall
  reader_object_ids             = [module.adf.adf_managed_identity]

  depends_on = [module.adf]
}
