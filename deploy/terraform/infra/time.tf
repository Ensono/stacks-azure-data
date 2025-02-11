
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
