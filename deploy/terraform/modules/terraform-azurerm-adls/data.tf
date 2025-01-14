data "azurerm_monitor_diagnostic_categories" "adls_log_analytics_categories" {
  for_each = {
    for account_name, account_details in var.storage_account_details : account_name => account_details
    if var.la_workspace_id != ""
  }
  resource_id = azurerm_storage_account.storage_account_default["${each.key}"].id

  depends_on = [azurerm_storage_account.storage_account_default]
}

data "azurerm_storage_account" "storage_id" {
  for_each            = var.storage_account_details
  name                = substr(replace("${var.resource_namer}${each.value.name}", "-", ""), 0, 24)
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_storage_account.storage_account_default]
}
