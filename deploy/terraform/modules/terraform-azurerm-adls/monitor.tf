resource "azurerm_monitor_diagnostic_setting" "adls_log_analytics" {
  for_each = {
    for account_name, account_details in var.storage_account_details : account_name => account_details
    if var.la_workspace_id != ""
  }

  name                           = "Storage to Log Analytics"
  target_resource_id             = azurerm_storage_account.storage_account_default["${each.key}"].id
  log_analytics_workspace_id     = var.la_workspace_id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.adls_log_analytics_categories[each.key].logs

    content {
      category = log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.adls_log_analytics_categories[each.key].metrics

    content {
      category = metric.value

    }
  }

  depends_on = [data.azurerm_monitor_diagnostic_categories.adls_log_analytics_categories]
}
