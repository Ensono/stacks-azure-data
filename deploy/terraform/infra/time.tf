
# Define a time resource which will be used to set the expiration date of secrets
# in the key vault. By doing this the time is set in the state and the secrets
# will not be updated on each Terraform run
resource "time_static" "datum" {}

# Create a sleep function, that will wait for a minute for all private endpoints to
# be created
resource "time_sleep" "wait_for_private_endpoints" {
  create_duration = "60s"

  depends_on = [
    azurerm_data_factory_managed_private_endpoint.db_auth_pe,
    azurerm_data_factory_managed_private_endpoint.db_pe,
    azurerm_data_factory_managed_private_endpoint.sql_pe,
    azurerm_data_factory_managed_private_endpoint.kv_pe,
    azurerm_data_factory_managed_private_endpoint.adls_pe,
    azurerm_data_factory_managed_private_endpoint.blob_pe
  ]
}

# Create a sleep function that will wait for 60 seconds, after the chosen
# resources have been created.
# The managed endpoints are then dependent on this resource which should mean
# everything is in place before the endpoints are attempted to be created
resource "time_sleep" "wait_for_resources" {
  create_duration = "60s"

  depends_on = [
    module.adf,
    module.adls_default,
    module.adb,
    module.kv_default,
    module.sql
  ]
}

# Create a time resource that waits for the log analytics workspace and the 
# databricks resouurce.
# This is so that the diagnostic setting can be deployed
resource "time_sleep" "wait_for_databricks_and_la" {
  create_duration = "60s"

  depends_on = [
    azurerm_log_analytics_workspace.la,
    module.adb
  ]
}
