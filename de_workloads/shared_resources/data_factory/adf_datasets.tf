resource "azurerm_data_factory_dataset_json" "ds_dp_ConfigStore_Json" {
  name                = "ds_dp_ConfigStore_Json"
  data_factory_id     = data.azurerm_data_factory.factory.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.ls_Blob_ConfigStore.name
  folder              = "Data_Platform/Config_Store"
  parameters = {
    filename  = "",
    path      = "",
    container = ""
  }
  azure_blob_storage_location {
    container                 = "@dataset().container"
    path                      = "@dataset().path"
    filename                  = "@dataset().filename"
    dynamic_container_enabled = true
    dynamic_path_enabled      = true
    dynamic_filename_enabled  = true
  }
  encoding = "UTF-8"
}


resource "azurerm_data_factory_dataset_parquet" "ds_dp_DataLake_Parquet" {
  name                = "ds_dp_DataLake_Parquet"
  data_factory_id     = data.azurerm_data_factory.factory.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.ls_ADLS_DataLake.name
  folder              = "Data_Platform/Data_Lake"
  parameters = {
    path     = "",
    filename = ""
  }
  azure_blob_storage_location {
    container                = "raw"
    path                     = "@dataset().path"
    filename                 = "@dataset().filename"
    dynamic_path_enabled     = true
    dynamic_filename_enabled = true
  }
  compression_codec = "snappy"
}
