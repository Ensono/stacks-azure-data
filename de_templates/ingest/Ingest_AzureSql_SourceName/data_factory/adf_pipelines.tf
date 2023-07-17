resource "azurerm_resource_group_template_deployment" "pipeline_Ingest_AzureSql_Example" {
  #   count           = var.include_data_quality == false ? 1 : 0
  name                = "pipeline_Ingest_AzureSql_Example"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = var.arm_deployment_mode
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/Ingest_AzureSql_Example.json")
  depends_on = [
    azurerm_data_factory_custom_dataset.ds_ex_AzureSql_ExampleSource
  ]
}

resource "azurerm_resource_group_template_deployment" "pipeline_Ingest_AzureSql_Example_DQ" {
  #   count           = var.include_data_quality == true ? 1 : 0
  name                = "pipeline_Ingest_AzureSql_Example_DQ"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = var.arm_deployment_mode
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/Ingest_AzureSql_Example_DQ.json")
  depends_on = [
    azurerm_data_factory_custom_dataset.ds_ex_AzureSql_ExampleSource
  ]
}
