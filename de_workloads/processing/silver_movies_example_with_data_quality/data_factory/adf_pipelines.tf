resource "azurerm_resource_group_template_deployment" "pipeline_silver_movies_example_with_data_quality" {
  name                = "pipeline_silver_movies_example_with_data_quality"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = var.arm_deployment_mode
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/arm_template.json")
}
