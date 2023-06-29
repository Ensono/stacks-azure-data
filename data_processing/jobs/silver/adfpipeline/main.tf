locals {
  factoryName = data.azurerm_data_factory.example.name
}

resource "azurerm_resource_group_template_deployment" "example" {
  name                = "Silver"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({

    "factoryName" = {
      value = local.factoryName
    }
    "adlsStorageAccountName" = {
      value = var.adlsStorageAccountName
    }

    "blobStorageAccountName" = {
      value = var.blobStorageAccountName
    }

    "databricksHost" = {
      value = var.databricksHost
    }

    "databricksWorkspaceResourceId" = {
      value = var.databricksWorkspaceResourceId
    }

    "enableDataQualitySilver" = {
      value = var.enableDataQualitySilver
    }
    

  })
  template_content = file("ARMTemplateForFactory.json")
}

