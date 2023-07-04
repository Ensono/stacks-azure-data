resource "azurerm_data_factory_pipeline" "pipeline_Get_Ingest_Config" {
  name            = "Get_Ingest_Config"
  data_factory_id = data.azurerm_data_factory.factory.id
  activities_json = file("${path.module}/pipelines/Get_Ingest_Config.json")
  description     = "Retrieve ingest config from the config store for the specified data source."
  folder          = "Utilities"
  parameters = {
    config_container = "config",
    config_path      = "",
    config_file      = ""
  }
  depends_on = [
    azurerm_data_factory_dataset_json.ds_dp_ConfigStore_Json
  ]
}

resource "azurerm_data_factory_pipeline" "pipeline_Generate_Ingest_Query" {
  name            = "Generate_Ingest_Query"
  data_factory_id = data.azurerm_data_factory.factory.id
  activities_json = file("${path.module}/pipelines/Generate_Ingest_Query.json")
  description     = "Generate an ingest query from the provided ingest entity configuration."
  folder          = "Utilities"
  parameters = {
    ingest_entity_config = "", # this param was previously Object type, may need converting in ADF
    window_start         = "",
    window_end           = ""
  }
  variables = {
    query = ""
  }
}
