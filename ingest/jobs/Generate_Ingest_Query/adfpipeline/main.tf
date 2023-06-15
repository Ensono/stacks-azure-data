locals {
  factoryName = data.azurerm_data_factory.example.name
}

resource "azurerm_resource_group_template_deployment" "example" {
  name                = "example-deploy"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "factoryName" = {
      value = local.factoryName
    }
  })
  template_content = file("ARMTemplateForFactory.json")
}
