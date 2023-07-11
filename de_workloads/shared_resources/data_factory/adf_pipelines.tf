resource "azurerm_resource_group_template_deployment" "pipeline_Get_Ingest_Config" {
  name                = "Get_Ingest_Config"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/Get_Ingest_Config.json")
}

resource "azurerm_resource_group_template_deployment" "pipeline_Generate_Ingest_Query" {
  name                = "Generate_Ingest_Query"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/Generate_Ingest_Query.json")
}
