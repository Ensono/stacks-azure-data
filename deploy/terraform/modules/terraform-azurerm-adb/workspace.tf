resource "azurerm_databricks_workspace" "example" {
  name                                  = var.resource_namer
  location                              = var.resource_group_location
  resource_group_name                   = var.resource_group_name
  sku                                   = var.databricks_sku
  public_network_access_enabled         = var.public_network_access_enabled
  network_security_group_rules_required = var.managed_vnet ? null : var.network_security_group_rules_required
  managed_resource_group_name           = "databricks-rg-${var.resource_group_name}"
  load_balancer_backend_address_pool_id = var.create_lb ? azurerm_lb_backend_address_pool.lb_be_pool[0].id : null

  dynamic "custom_parameters" {
    for_each = var.enable_private_network == false ? toset([]) : toset([1])
    content {
      no_public_ip                                         = true
      public_subnet_name                                   = var.managed_vnet ? null : var.public_subnet_name
      private_subnet_name                                  = var.managed_vnet ? null : var.private_subnet_name
      virtual_network_id                                   = var.managed_vnet ? null : var.virtual_network_id
      vnet_address_prefix                                  = var.managed_vnet ? null : (var.vnet_address_prefix == "" ? null : var.vnet_address_prefix)
      public_subnet_network_security_group_association_id  = var.managed_vnet ? null : var.adf_private_nsg_subnet_association_id
      private_subnet_network_security_group_association_id = var.managed_vnet ? null : var.adf_public_nsg_subnet_association_id
      nat_gateway_name                                     = var.managed_vnet ? null : local.nat_gateway_name
      public_ip_name                                       = var.managed_vnet ? null : local.public_ip_name
    }
  }


  tags = var.resource_tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

}
