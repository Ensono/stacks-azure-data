resource "azurerm_private_endpoint" "databricks" {
  count = var.enable_private_network && var.managed_vnet == false ? 1 : 0

  name                = "${var.resource_namer}-pe-databricks"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.resource_namer}-db-pe"
    private_connection_resource_id = azurerm_databricks_workspace.example.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {

    name                 = "databricks_ui_api"
    private_dns_zone_ids = ["${var.private_dns_zone_id}"]
  }

  depends_on = [azurerm_databricks_workspace.example]

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_private_endpoint" "auth" {
  count               = var.enable_private_network && var.managed_vnet == false && var.browser_authentication_enabled == true ? 1 : 0
  name                = "${var.resource_namer}-pe-databricks-auth"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.resource_namer}-db-pe-auth"
    private_connection_resource_id = azurerm_databricks_workspace.example.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  private_dns_zone_group {
    name                 = "databricks_auth"
    private_dns_zone_ids = ["${var.private_dns_zone_id}"]
  }

  depends_on = [azurerm_databricks_workspace.example]

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

}
