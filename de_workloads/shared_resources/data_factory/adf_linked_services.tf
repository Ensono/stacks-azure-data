resource "azurerm_data_factory_linked_service_azure_blob_storage" "ls_Blob_ConfigStore" {
  name                     = "ls_Blob_ConfigStore"
  data_factory_id          = data.azurerm_data_factory.factory.id
  integration_runtime_name = var.integration_runtime_name
  use_managed_identity     = true
  service_endpoint         = var.blob_configstore_endpoint
  storage_kind             = "BlobStorage"
}

resource "azurerm_data_factory_linked_service_key_vault" "ls_KeyVault" {
  name            = "ls_KeyVault"
  data_factory_id = data.azurerm_data_factory.factory.id
  key_vault_id    = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "ls_ADLS_DataLake" {
  name                     = "ls_ADLS_DataLake"
  data_factory_id          = data.azurerm_data_factory.factory.id
  integration_runtime_name = var.integration_runtime_name
  use_managed_identity     = true
  url                      = var.adls_datalake_url
}

resource "azurerm_data_factory_linked_service_azure_databricks" "ls_Databricks_Small" {
  count                      = var.include_databricks_resources ? 1 : 0
  name                       = "ls_Databricks_Small"
  data_factory_id            = data.azurerm_data_factory.factory.id
  integration_runtime_name   = var.integration_runtime_name
  adb_domain                 = var.databricks_workspace_url
  msi_work_space_resource_id = var.databricks_workspace_resource_id

  new_cluster_config {
    node_type             = "Standard_DS3_v2"
    cluster_version       = "13.3.x-scala2.12"
    min_number_of_workers = 2
    max_number_of_workers = 2
    spark_environment_variables = {
      AZURE_CLIENT_SECRET = "{{secrets/key-vault-backed/service-principal-secret}}"
      AZURE_CLIENT_ID     = "{{secrets/key-vault-backed/azure-client-id}}"
      AZURE_TENANT_ID     = "{{secrets/key-vault-backed/azure-tenant-id}}"
      ADLS_ACCOUNT        = var.adls_datalake_name
      CONFIG_BLOB_ACCOUNT = var.blob_configstore_name
      PYSPARK_PYTHON      = "/databricks/python3/bin/python3"
    }
  }
}
