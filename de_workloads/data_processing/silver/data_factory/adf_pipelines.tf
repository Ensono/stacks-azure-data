resource "random_uuid" "deployment" {
}

resource "azurerm_resource_group_template_deployment" "pipeline_silver" {
  #   count               = var.include_data_quality == false ? 1 : 0
  name                = "silver-${random_uuid.deployment.result}"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = var.arm_deployment_mode
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/silver.json")
}

resource "azurerm_resource_group_template_deployment" "pipeline_silver_dq" {
  #   count               = var.include_data_quality == true ? 1 : 0
  name                = "silver_dq-${random_uuid.deployment.result}"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = var.arm_deployment_mode
  parameters_content = jsonencode({
    "factoryName" = {
      value = data.azurerm_data_factory.factory.name
    }
  })
  template_content = file("${path.module}/pipelines/silver_dq.json")
}
