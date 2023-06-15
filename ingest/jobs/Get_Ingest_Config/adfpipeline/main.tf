locals {
  factoryName = data.azurerm_data_factory.example.name
}

resource "azurerm_resource_group_template_deployment" "example" {
  name                = "get-ingest-config"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "ls_Blob_ConfigStore_properties_typeProperties_serviceEndpoint" = {
      value = var.ls_Blob_ConfigStore_properties_typeProperties_serviceEndpoint
    }
        "factoryName" = {
      value = local.factoryName
    }

  })
  template_content = file("ARMTemplateForFactory.json")
}
