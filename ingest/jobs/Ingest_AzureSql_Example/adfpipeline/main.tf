locals {
  factoryName = data.azurerm_data_factory.example.name
}

resource "azurerm_resource_group_template_deployment" "example" {
  name                = "Ingest_AzureSql_Example"
  resource_group_name = var.data_factory_resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "ls_Blob_ConfigStore_properties_typeProperties_serviceEndpoint" = {
      value = var.ls_Blob_ConfigStore_properties_typeProperties_serviceEndpoint
    }
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

    "ls_ADLS_DataLake_properties_typeProperties_url" = {
      value = var.ls_ADLS_DataLake_properties_typeProperties_url
    }
    "ls_KeyVault_properties_typeProperties_baseUrl" = {
      value = var.ls_KeyVault_properties_typeProperties_baseUrl
    }
    "ls_AzureSql_ExampleSource_connectionString" = {
      value = var.ls_AzureSql_ExampleSource_connectionString
    }
    "enableDataQualityIngest" = {
      value = var.enableDataQualityIngest
    }

  })
 template_content = file("ARMTemplateForFactory.json") 
}
