resource "azurerm_monitor_diagnostic_setting" "databricks_log_analytics" {
  count                      = var.enable_databricksws_diagnostic ? 1 : 0
  name                       = var.databricksws_diagnostic_setting_name
  target_resource_id         = azurerm_databricks_workspace.example.id
  log_analytics_workspace_id = var.data_platform_log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.adb_log_analytics_categories.log_category_types

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.adb_log_analytics_categories.metrics

    content {
      category = metric.value

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

}
