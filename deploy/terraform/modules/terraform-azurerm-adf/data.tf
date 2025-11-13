data "azurerm_monitor_diagnostic_categories" "adf_log_analytics_categories" {
  count       = var.la_workspace_id != "" ? 1 : 0
  resource_id = azurerm_data_factory.example[0].id

  depends_on = [azurerm_data_factory.example]
}
