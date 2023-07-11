resource "azurerm_resource_group_template_deployment" "pipeline_Get_Ingest_Config_PM" {
  name                = "PM_Get_Ingest_Config"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/ARM_Get_Ingest_Config.json")
}

resource "azurerm_data_factory_pipeline" "pipeline_Get_Ingest_Config" {
  name            = "NEW_Get_Ingest_Config"
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

resource "azurerm_resource_group_template_deployment" "pipeline_Generate_Ingest_Query_PM" {
  name                = "PM_Generate_Ingest_Query"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/ARM_Generate_Ingest_Query.json")
}

resource "azurerm_data_factory_pipeline" "pipeline_Generate_Ingest_Query" {
  name            = "NEW_Generate_Ingest_Query"
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
