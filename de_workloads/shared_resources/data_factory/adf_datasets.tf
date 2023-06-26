resource "azurerm_data_factory_dataset_json" "ds_dp_ConfigStore_Json" {
  name                = "ds_dp_ConfigStore_Json"
  resource_group_name = var.resource_group_name
  data_factory_name   = var.adf_account_name
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.ls_Blob_ConfigStore.name
  folder              = "Data_Platform/Config_Store"
  parameters = {
    filename  = "",
    path      = "",
    container = ""
  }
  azure_blob_storage_location {
    container                = "@dataset().container"
    folderPath               = "@dataset().path"
    fileName                 = "@dataset().filename"
    dynamic_filename_enabled = true
  }
  encoding = "UTF-8"
}
