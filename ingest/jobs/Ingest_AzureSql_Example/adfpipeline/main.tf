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
 /* template_content = file("ARMTemplateForFactory.json")  */
 template_content = <<TEMPLATE
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "factoryName": {
            "type": "string",
            "metadata": "Data Factory name",
            "defaultValue": "amido-stacks-dev-euw-de"
        },
        "adlsStorageAccountName": {
            "type": "string",
            "defaultValue": "amidostacksdeveuwdeadls"
        },
        "blobStorageAccountName": {
            "type": "string",
            "defaultValue": "amidostacksdeveuwdeconfi"
        },
        "databricksHost": {
            "type": "string",
            "defaultValue": "https://xxxxxxxxx.azuredatabricks.net"
        },
        "databricksWorkspaceResourceId": {
            "type": "string",
            "defaultValue": "/subscriptions/xxxxxxxxxxx/resourceGroups/xxxxxxxx/providers/Microsoft.Databricks/workspaces/xxxxxxxxxxx"
        },
        "ls_Blob_ConfigStore_properties_typeProperties_serviceEndpoint": {
            "type": "string",
            "defaultValue": "https://amidostacksdeveuwdeconfi.blob.core.windows.net/"
        },
        "ls_ADLS_DataLake_properties_typeProperties_url": {
            "type": "string",
            "defaultValue": "https://amidostacksdeveuwdeadls.dfs.core.windows.net/"
        },
        "ls_KeyVault_properties_typeProperties_baseUrl": {
            "type": "string",
            "defaultValue": "https://amidostacksdeveuwde.vault.azure.net/"
        },
        "ls_AzureSql_ExampleSource_connectionString": {
            "type": "secureString",
            "metadata": "Secure string for 'connectionString' of 'ls_AzureSql_ExampleSource'"
        },
        "enableDataQualityIngest": {
            "type": "bool",
            "defaultValue": true
        }
    },
    "variables": {
        "factoryId": "[concat('Microsoft.DataFactory/factories/', parameters('factoryName'))]"
    },
    "resources": [
        {
            "condition": "[not(parameters('enableDataQualityIngest'))]",
            "name": "[concat(parameters('factoryName'), '/Ingest_AzureSql_Example')]",
            "type": "Microsoft.DataFactory/factories/pipelines",
            "apiVersion": "2018-06-01",
            "properties": {
                "description": "Ingest from demo Azure SQL database using ingest config file.",
                "activities": [
                    {
                        "name": "Get_Ingest_Config",
                        "type": "ExecutePipeline",
                        "dependsOn": [],
                        "userProperties": [],
                        "typeProperties": {
                            "pipeline": {
                                "referenceName": "Get_Ingest_Config",
                                "type": "PipelineReference"
                            },
                            "waitOnCompletion": true,
                            "parameters": {
                                "config_file": {
                                    "value": "@{pipeline().parameters.data_source_name}.json",
                                    "type": "Expression"
                                }
                            }
                        }
                    },
                    {
                        "name": "For_Each_Ingest_Entity",
                        "type": "ForEach",
                        "dependsOn": [
                            {
                                "activity": "Get_Ingest_Config",
                                "dependencyConditions": [
                                    "Succeeded"
                                ]
                            }
                        ],
                        "userProperties": [],
                        "typeProperties": {
                            "items": {
                                "value": "@activity('Get_Ingest_Config').output.pipelineReturnValue['config'][0]['ingest_entities']",
                                "type": "Expression"
                            },
                            "isSequential": false,
                            "activities": [
                                {
                                    "name": "SQL_to_ADLS",
                                    "type": "Copy",
                                    "dependsOn": [
                                        {
                                            "activity": "Generate_Ingest_Query",
                                            "dependencyConditions": [
                                                "Succeeded"
                                            ]
                                        }
                                    ],
                                    "policy": {
                                        "timeout": "1:00:00",
                                        "retry": 0,
                                        "retryIntervalInSeconds": 30,
                                        "secureOutput": false,
                                        "secureInput": false
                                    },
                                    "userProperties": [],
                                    "typeProperties": {
                                        "source": {
                                            "type": "AzureSqlSource",
                                            "additionalColumns": [
                                                {
                                                    "name": "meta_ingestion_datetime",
                                                    "value": {
                                                        "value": "@utcNow()",
                                                        "type": "Expression"
                                                    }
                                                },
                                                {
                                                    "name": "meta_ingestion_pipeline",
                                                    "value": {
                                                        "value": "@pipeline().Pipeline",
                                                        "type": "Expression"
                                                    }
                                                },
                                                {
                                                    "name": "meta_ingestion_run_id",
                                                    "value": {
                                                        "value": "@pipeline().RunId",
                                                        "type": "Expression"
                                                    }
                                                }
                                            ],
                                            "sqlReaderQuery": {
                                                "value": "@activity('Generate_Ingest_Query').output.pipelineReturnValue['generated_query']",
                                                "type": "Expression"
                                            },
                                            "queryTimeout": "00:10:00",
                                            "partitionOption": "None"
                                        },
                                        "sink": {
                                            "type": "ParquetSink",
                                            "storeSettings": {
                                                "type": "AzureBlobFSWriteSettings"
                                            },
                                            "formatSettings": {
                                                "type": "ParquetWriteSettings"
                                            }
                                        },
                                        "enableStaging": false,
                                        "validateDataConsistency": true,
                                        "logSettings": {
                                            "enableCopyActivityLog": true,
                                            "copyActivityLogSettings": {
                                                "logLevel": "Warning",
                                                "enableReliableLogging": false
                                            },
                                            "logLocationSettings": {
                                                "linkedServiceName": {
                                                    "referenceName": "ls_Blob_ConfigStore",
                                                    "type": "LinkedServiceReference"
                                                },
                                                "path": {
                                                    "value": "adf-config/logs/@{pipeline().Pipeline}/@{item()['display_name']}",
                                                    "type": "Expression"
                                                }
                                            }
                                        },
                                        "translator": {
                                            "type": "TabularTranslator",
                                            "typeConversion": true,
                                            "typeConversionSettings": {
                                                "allowDataTruncation": true,
                                                "treatBooleanAsNumber": false
                                            }
                                        }
                                    },
                                    "inputs": [
                                        {
                                            "referenceName": "ds_ex_AzureSql_ExampleSource",
                                            "type": "DatasetReference",
                                            "parameters": {}
                                        }
                                    ],
                                    "outputs": [
                                        {
                                            "referenceName": "ds_dp_DataLake_Parquet",
                                            "type": "DatasetReference",
                                            "parameters": {
                                                "directory": {
                                                    "value": "@{pipeline().parameters.data_source_name}/@{item()['display_name']}/v@{string(item()['version'])}/@{item()['load_type']}/@{pipeline().parameters.window_start}/@{if(empty(pipeline().parameters.correlation_id), pipeline().RunId, pipeline().parameters.correlation_id)}",
                                                    "type": "Expression"
                                                },
                                                "filename": {
                                                    "value": "@{item()['display_name']}.parquet",
                                                    "type": "Expression"
                                                }
                                            }
                                        }
                                    ]
                                },
                                {
                                    "name": "Generate_Ingest_Query",
                                    "type": "ExecutePipeline",
                                    "dependsOn": [],
                                    "userProperties": [],
                                    "typeProperties": {
                                        "pipeline": {
                                            "referenceName": "Generate_Ingest_Query",
                                            "type": "PipelineReference"
                                        },
                                        "waitOnCompletion": true,
                                        "parameters": {
                                            "ingest_entity_config": {
                                                "value": "@item()",
                                                "type": "Expression"
                                            },
                                            "window_start": {
                                                "value": "@pipeline().parameters.window_start",
                                                "type": "Expression"
                                            },
                                            "window_end": {
                                                "value": "@pipeline().parameters.window_end",
                                                "type": "Expression"
                                            }
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ],
                "policy": {
                    "elapsedTimeMetric": {},
                    "cancelAfter": {}
                },
                "parameters": {
                    "data_source_name": {
                        "type": "string",
                        "defaultValue": "example_azuresql_1"
                    },
                    "window_start": {
                        "type": "string",
                        "defaultValue": "2020-01-01"
                    },
                    "window_end": {
                        "type": "string",
                        "defaultValue": "2020-01-31"
                    },
                    "correlation_id": {
                        "type": "string"
                    }
                },
                "folder": {
                    "name": "Ingest"
                },
                "annotations": [],
                "lastPublishTime": "2023-05-15T11:08:48Z"
            },
            "dependsOn": [
                "[concat(variables('factoryId'), '/datasets/ds_ex_AzureSql_ExampleSource')]",
                "[concat(variables('factoryId'), '/datasets/ds_dp_DataLake_Parquet')]",
                "[concat(variables('factoryId'), '/linkedServices/ls_Blob_ConfigStore')]"
            ]
        },
        {
            "condition": "[parameters('enableDataQualityIngest')]",
            "name": "[concat(parameters('factoryName'), '/Ingest_AzureSql_Example_DQ')]",
            "type": "Microsoft.DataFactory/factories/pipelines",
            "apiVersion": "2018-06-01",
            "properties": {
                "description": "Ingest from demo Azure SQL database using ingest config file.",
                "activities": [
                    {
                        "name": "Get_Ingest_Config",
                        "type": "ExecutePipeline",
                        "dependsOn": [],
                        "userProperties": [],
                        "typeProperties": {
                            "pipeline": {
                                "referenceName": "Get_Ingest_Config",
                                "type": "PipelineReference"
                            },
                            "waitOnCompletion": true,
                            "parameters": {
                                "config_file": {
                                    "value": "@{pipeline().parameters.data_source_name}.json",
                                    "type": "Expression"
                                }
                            }
                        }
                    },
                    {
                        "name": "For_Each_Ingest_Entity",
                        "type": "ForEach",
                        "dependsOn": [
                            {
                                "activity": "Get_Ingest_Config",
                                "dependencyConditions": [
                                    "Succeeded"
                                ]
                            }
                        ],
                        "userProperties": [],
                        "typeProperties": {
                            "items": {
                                "value": "@activity('Get_Ingest_Config').output.pipelineReturnValue['config'][0]['ingest_entities']",
                                "type": "Expression"
                            },
                            "isSequential": false,
                            "activities": [
                                {
                                    "name": "SQL_to_ADLS",
                                    "type": "Copy",
                                    "dependsOn": [
                                        {
                                            "activity": "Generate_Ingest_Query",
                                            "dependencyConditions": [
                                                "Succeeded"
                                            ]
                                        }
                                    ],
                                    "policy": {
                                        "timeout": "1:00:00",
                                        "retry": 0,
                                        "retryIntervalInSeconds": 30,
                                        "secureOutput": false,
                                        "secureInput": false
                                    },
                                    "userProperties": [],
                                    "typeProperties": {
                                        "source": {
                                            "type": "AzureSqlSource",
                                            "additionalColumns": [
                                                {
                                                    "name": "meta_ingestion_datetime",
                                                    "value": {
                                                        "value": "@utcNow()",
                                                        "type": "Expression"
                                                    }
                                                },
                                                {
                                                    "name": "meta_ingestion_pipeline",
                                                    "value": {
                                                        "value": "@pipeline().Pipeline",
                                                        "type": "Expression"
                                                    }
                                                },
                                                {
                                                    "name": "meta_ingestion_run_id",
                                                    "value": {
                                                        "value": "@pipeline().RunId",
                                                        "type": "Expression"
                                                    }
                                                }
                                            ],
                                            "sqlReaderQuery": {
                                                "value": "@activity('Generate_Ingest_Query').output.pipelineReturnValue['generated_query']",
                                                "type": "Expression"
                                            },
                                            "queryTimeout": "00:10:00",
                                            "partitionOption": "None"
                                        },
                                        "sink": {
                                            "type": "ParquetSink",
                                            "storeSettings": {
                                                "type": "AzureBlobFSWriteSettings"
                                            },
                                            "formatSettings": {
                                                "type": "ParquetWriteSettings"
                                            }
                                        },
                                        "enableStaging": false,
                                        "validateDataConsistency": true,
                                        "logSettings": {
                                            "enableCopyActivityLog": true,
                                            "copyActivityLogSettings": {
                                                "logLevel": "Warning",
                                                "enableReliableLogging": false
                                            },
                                            "logLocationSettings": {
                                                "linkedServiceName": {
                                                    "referenceName": "ls_Blob_ConfigStore",
                                                    "type": "LinkedServiceReference"
                                                },
                                                "path": {
                                                    "value": "adf-config/logs/@{pipeline().Pipeline}/@{item()['display_name']}",
                                                    "type": "Expression"
                                                }
                                            }
                                        },
                                        "translator": {
                                            "type": "TabularTranslator",
                                            "typeConversion": true,
                                            "typeConversionSettings": {
                                                "allowDataTruncation": true,
                                                "treatBooleanAsNumber": false
                                            }
                                        }
                                    },
                                    "inputs": [
                                        {
                                            "referenceName": "ds_ex_AzureSql_ExampleSource",
                                            "type": "DatasetReference",
                                            "parameters": {}
                                        }
                                    ],
                                    "outputs": [
                                        {
                                            "referenceName": "ds_dp_DataLake_Parquet",
                                            "type": "DatasetReference",
                                            "parameters": {
                                                "directory": {
                                                    "value": "@{pipeline().parameters.data_source_name}/@{item()['display_name']}/v@{string(item()['version'])}/@{item()['load_type']}/@{pipeline().parameters.window_start}/@{if(empty(pipeline().parameters.correlation_id), pipeline().RunId, pipeline().parameters.correlation_id)}",
                                                    "type": "Expression"
                                                },
                                                "filename": {
                                                    "value": "@{item()['display_name']}.parquet",
                                                    "type": "Expression"
                                                }
                                            }
                                        }
                                    ]
                                },
                                {
                                    "name": "Generate_Ingest_Query",
                                    "type": "ExecutePipeline",
                                    "dependsOn": [],
                                    "userProperties": [],
                                    "typeProperties": {
                                        "pipeline": {
                                            "referenceName": "Generate_Ingest_Query",
                                            "type": "PipelineReference"
                                        },
                                        "waitOnCompletion": true,
                                        "parameters": {
                                            "ingest_entity_config": {
                                                "value": "@item()",
                                                "type": "Expression"
                                            },
                                            "window_start": {
                                                "value": "@pipeline().parameters.window_start",
                                                "type": "Expression"
                                            },
                                            "window_end": {
                                                "value": "@pipeline().parameters.window_end",
                                                "type": "Expression"
                                            }
                                        }
                                    }
                                }
                            ]
                        }
                    },
                    {
                        "name": "Data_Quality",
                        "type": "DatabricksSparkPython",
                        "dependsOn": [
                            {
                                "activity": "For_Each_Ingest_Entity",
                                "dependencyConditions": [
                                    "Succeeded"
                                ]
                            }
                        ],
                        "policy": {
                            "timeout": "0.12:00:00",
                            "retry": 0,
                            "retryIntervalInSeconds": 30,
                            "secureOutput": false,
                            "secureInput": false
                        },
                        "userProperties": [],
                        "typeProperties": {
                            "pythonFile": "dbfs:/FileStore/scripts/ingest_dq.py",
                            "parameters": [],
                            "libraries": [
                                {
                                    "whl": "dbfs:/FileStore/jars/pysparkle-latest-py3-none-any.whl"
                                }
                            ]
                        },
                        "linkedServiceName": {
                            "referenceName": "ls_Databricks_Small",
                            "type": "LinkedServiceReference"
                        }
                    }
                ],
                "policy": {
                    "elapsedTimeMetric": {},
                    "cancelAfter": {}
                },
                "parameters": {
                    "data_source_name": {
                        "type": "string",
                        "defaultValue": "example_azuresql_1"
                    },
                    "window_start": {
                        "type": "string",
                        "defaultValue": "2020-01-01"
                    },
                    "window_end": {
                        "type": "string",
                        "defaultValue": "2020-01-31"
                    },
                    "correlation_id": {
                        "type": "string"
                    }
                },
                "folder": {
                    "name": "Ingest"
                },
                "annotations": [],
                "lastPublishTime": "2023-06-09T13:41:42Z"
            },
            "dependsOn": [
                "[concat(variables('factoryId'), '/linkedServices/ls_Databricks_Small')]",
                "[concat(variables('factoryId'), '/datasets/ds_ex_AzureSql_ExampleSource')]",
                "[concat(variables('factoryId'), '/datasets/ds_dp_DataLake_Parquet')]",
                "[concat(variables('factoryId'), '/linkedServices/ls_Blob_ConfigStore')]"
            ]
        },
        {
            "name": "[concat(parameters('factoryName'), '/ds_dp_DataLake_Parquet')]",
            "type": "Microsoft.DataFactory/factories/datasets",
            "apiVersion": "2018-06-01",
            "properties": {
                "linkedServiceName": {
                    "referenceName": "ls_ADLS_DataLake",
                    "type": "LinkedServiceReference"
                },
                "parameters": {
                    "directory": {
                        "type": "String"
                    },
                    "filename": {
                        "type": "String"
                    }
                },
                "folder": {
                    "name": "Data_Platform/Data_Lake"
                },
                "annotations": [],
                "type": "Parquet",
                "typeProperties": {
                    "location": {
                        "type": "AzureBlobStorageLocation",
                        "fileName": {
                            "value": "@dataset().filename",
                            "type": "Expression"
                        },
                        "folderPath": {
                            "value": "@dataset().directory",
                            "type": "Expression"
                        },
                        "container": "raw"
                    },
                    "compressionCodec": "snappy"
                },
                "schema": []
            },
            "dependsOn": [
                "[concat(variables('factoryId'), '/linkedServices/ls_ADLS_DataLake')]"
            ]
        },
        {
            "name": "[concat(parameters('factoryName'), '/adf-managed-vnet-runtime')]",
            "type": "Microsoft.DataFactory/factories/integrationRuntimes",
            "apiVersion": "2018-06-01",
            "properties": {
                "type": "Managed",
                "typeProperties": {
                    "computeProperties": {
                        "location": "West Europe",
                        "dataFlowProperties": {
                            "computeType": "General",
                            "coreCount": 8,
                            "timeToLive": 0,
                            "cleanup": true
                        }
                    }
                },
                "managedVirtualNetwork": {
                    "type": "ManagedVirtualNetworkReference",
                    "referenceName": "default"
                }
            },
            "dependsOn": [

            ]
        },
        {
            "name": "[concat(parameters('factoryName'), '/ds_ex_AzureSql_ExampleSource')]",
            "type": "Microsoft.DataFactory/factories/datasets",
            "apiVersion": "2018-06-01",
            "properties": {
                "linkedServiceName": {
                    "referenceName": "ls_AzureSql_ExampleSource",
                    "type": "LinkedServiceReference"
                },
                "folder": {
                    "name": "External_Sources"
                },
                "annotations": [],
                "type": "AzureSqlTable",
                "schema": [],
                "typeProperties": {}
            },
            "dependsOn": [
                "[concat(variables('factoryId'), '/linkedServices/ls_AzureSql_ExampleSource')]"
            ]
        },
        {
            "name": "[concat(parameters('factoryName'), '/ls_Blob_ConfigStore')]",
            "type": "Microsoft.DataFactory/factories/linkedServices",
            "apiVersion": "2018-06-01",
            "properties": {
                "annotations": [],
                "type": "AzureBlobStorage",
                "typeProperties": {
                    "serviceEndpoint": "[parameters('ls_Blob_ConfigStore_properties_typeProperties_serviceEndpoint')]",
                    "accountKind": "BlobStorage"
                },
                "connectVia": {
                    "referenceName": "adf-managed-vnet-runtime",
                    "type": "IntegrationRuntimeReference"
                }
            },
            "dependsOn": [
                "[concat(variables('factoryId'), '/integrationRuntimes/adf-managed-vnet-runtime')]"
            ]
        },
        {
            "name": "[concat(parameters('factoryName'), '/ls_ADLS_DataLake')]",
            "type": "Microsoft.DataFactory/factories/linkedServices",
            "apiVersion": "2018-06-01",
            "properties": {
                "annotations": [],
                "type": "AzureBlobFS",
                "typeProperties": {
                    "url": "[parameters('ls_ADLS_DataLake_properties_typeProperties_url')]"
                },
                "connectVia": {
                    "referenceName": "adf-managed-vnet-runtime",
                    "type": "IntegrationRuntimeReference"
                }
            },
            "dependsOn": [
                "[concat(variables('factoryId'), '/integrationRuntimes/adf-managed-vnet-runtime')]"
            ]
        },
        {
            "name": "[concat(parameters('factoryName'), '/ls_KeyVault')]",
            "type": "Microsoft.DataFactory/factories/linkedServices",
            "apiVersion": "2018-06-01",
            "properties": {
                "annotations": [],
                "type": "AzureKeyVault",
                "typeProperties": {
                    "baseUrl": "[parameters('ls_KeyVault_properties_typeProperties_baseUrl')]"
                }
            },
            "dependsOn": []
        },
        {
            "name": "[concat(parameters('factoryName'), '/ls_AzureSql_ExampleSource')]",
            "type": "Microsoft.DataFactory/factories/linkedServices",
            "apiVersion": "2018-06-01",
            "properties": {
                "description": "Azure SQL example linked service. These properties will may over overridden when deployed to other environments.\nTODO: Add password to KV.",
                "annotations": [],
                "type": "AzureSqlDatabase",
                "typeProperties": {
                    "connectionString": "[parameters('ls_AzureSql_ExampleSource_connectionString')]",
                    "password": {
                        "type": "AzureKeyVaultSecret",
                        "store": {
                            "referenceName": "ls_KeyVault",
                            "type": "LinkedServiceReference"
                        },
                        "secretName": "sql-password"
                    }
                },
                "connectVia": {
                    "referenceName": "adf-managed-vnet-runtime",
                    "type": "IntegrationRuntimeReference"
                }
            },
            "dependsOn": [
                "[concat(variables('factoryId'), '/integrationRuntimes/adf-managed-vnet-runtime')]",
                "[concat(variables('factoryId'), '/linkedServices/ls_KeyVault')]"
            ]
        },
        {
            "condition": "[parameters('enableDataQualityIngest')]",
            "name": "[concat(parameters('factoryName'), '/ls_Databricks_Small')]",
            "type": "Microsoft.DataFactory/factories/linkedServices",
            "apiVersion": "2018-06-01",
            "properties": {
                "annotations": [],
                "type": "AzureDatabricks",
                "typeProperties": {
                    "domain": "[parameters('databricksHost')]",
                    "authentication": "MSI",
                    "workspaceResourceId": "[parameters('databricksWorkspaceResourceId')]",
                    "newClusterNodeType": "Standard_DS3_v2",
                    "newClusterNumOfWorker": "2",
                    "newClusterSparkEnvVars": {   
                        "AZURE_CLIENT_SECRET": "{{secrets/key-vault-secret/service-principal-secret}}",
                        "AZURE_CLIENT_ID": "{{secrets/key-vault-secret/azure-client-id}}",
                        "AZURE_TENANT_ID": "{{secrets/key-vault-secret/azure-tenant-id}}",
                        "ADLS_ACCOUNT": "[parameters('adlsStorageAccountName')]",
                        "BLOB_ACCOUNT": "[parameters('blobStorageAccountName')]",
                        "PYSPARK_PYTHON": "/databricks/python3/bin/python3"
                    },
                    "newClusterVersion": "13.0.x-scala2.12",
                    "clusterOption": "Fixed",
                    "newClusterInitScripts": []
                }
            },
            "dependsOn": []
        }
    ]
}

 TEMPLATE
}
