resource "azurerm_data_factory_linked_service_azure_blob_storage" "ls_Blob_ConfigStore" {
  name                     = "ls_Blob_ConfigStore"
  resource_group_name      = var.resource_group_name
  data_factory_name        = var.adf_account_name
  integration_runtime_name = var.integration_runtime_name
  use_managed_identity     = true
  service_endpoint         = var.blob_configstore_endpoint
  storage_storage_kind     = "BlobStorage"
}
