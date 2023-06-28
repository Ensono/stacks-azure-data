resource "azurerm_data_factory_linked_service_azure_blob_storage" "ls_Blob_ConfigStore" {
  name                     = "ls_Blob_ConfigStore"
  resource_group_name      = var.resource_group_name
  data_factory_name        = var.adf_account_name
  integration_runtime_name = var.integration_runtime_name
  use_managed_identity     = true
  service_endpoint         = var.blob_configstore_endpoint
  storage_storage_kind     = "BlobStorage"
}

resource "azurerm_data_factory_linked_service_key_vault" "ls_KeyVault" {
  name                = "ls_KeyVault"
  resource_group_name = var.resource_group_name
  data_factory_name   = var.adf_account_name
  key_vault_id        = var.key_vault_id
}


resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "ls_ADLS_DataLake" {
  name                     = "ls_ADLS_DataLake"
  resource_group_name      = var.resource_group_name
  data_factory_name        = var.adf_account_name
  integration_runtime_name = var.integration_runtime_name
  use_managed_identity     = true
  url                      = var.adls_datalake_url
}

# Make this resource conditional
resource "azurerm_data_factory_linked_service_azure_databricks" "ls_Databricks_Small" {
  name                       = "ls_Databricks_Small"
  resource_group_name        = var.resource_group_name
  data_factory_name          = var.adf_account_name
  integration_runtime_name   = var.integration_runtime_name
  adb_domain                 = var.databricks_domain
  msi_work_space_resource_id = var.databricks_workspace_id

  new_cluster_config {
    node_type             = "Standard_DS3_v2"
    cluster_version       = "13.0.x-scala2.12"
    min_number_of_workers = 2
    max_number_of_workers = 2
    spark_environment_variables = {
      AZURE_CLIENT_SECRET = "{{secrets/key-vault-secret/service-principal-secret}}"
      AZURE_CLIENT_ID     = "{{secrets/key-vault-secret/azure-client-id}}"
      AZURE_TENANT_ID     = "{{secrets/key-vault-secret/azure-tenant-id}}"
      ADLS_ACCOUNT        = var.adls_datalake_name
      BLOB_ACCOUNT        = var.blob_configstore_name
      PYSPARK_PYTHON      = "/databricks/python3/bin/python3"
    }
  }
}
