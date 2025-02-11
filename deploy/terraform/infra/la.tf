resource "azurerm_log_analytics_workspace" "la" {
  name                = module.label_default.id
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = var.la_sku
  retention_in_days   = var.la_retention
  tags                = module.label_default.tags
}

#resource "azurerm_monitor_diagnostic_setting" "adf_log_analytics" {
#  name                           = "ADF to Log Analytics - Test"
#  target_resource_id             = module.adf.adf_factory_id
#  log_analytics_workspace_id     = azurerm_log_analytics_workspace.la.id
#  log_analytics_destination_type = "Dedicated"

#  dynamic "enabled_log" {
#    for_each = data.azurerm_monitor_diagnostic_categories.adf_log_analytics_categories.log_category_types
#    content {
#      category = enabled_log.value
#    }
#  }

#  dynamic "metric" {
#    for_each = data.azurerm_monitor_diagnostic_categories.adf_log_analytics_categories.metrics

#    content {
#      category = metric.value
#    }
#  }
#}
