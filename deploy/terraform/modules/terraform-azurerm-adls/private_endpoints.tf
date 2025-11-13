resource "azurerm_private_endpoint" "pe_dfs" {
  for_each = {
    for account_name, account_details in var.storage_account_details : account_name => account_details
    if var.enable_private_network && account_details.hns_enabled
  }
  name                = "${var.resource_namer}-storage-${each.value.name}-pe-dfs"
  resource_group_name = var.pe_resource_group_name
  location            = var.pe_resource_group_location
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.resource_namer}-storage-${each.value.name}-pe-dfs"
    private_connection_resource_id = azurerm_storage_account.storage_account_default[each.key].id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = azurerm_storage_account.storage_account_default[each.key].name
    private_dns_zone_ids = [var.dfs_private_zone_id]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_private_endpoint" "pe_blob" {
  for_each = {
    for account_name, account_details in var.storage_account_details : account_name => account_details
    if var.enable_private_network
  }
  name                = "${var.resource_namer}-storage-${each.value.name}-pe-blob"
  resource_group_name = var.pe_resource_group_name
  location            = var.pe_resource_group_location
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.resource_namer}-storage-${each.value.name}-pe-blob"
    private_connection_resource_id = azurerm_storage_account.storage_account_default[each.key].id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = azurerm_storage_account.storage_account_default[each.key].name
    private_dns_zone_ids = [var.blob_private_zone_id]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
