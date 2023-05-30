# PySparkle Usage

## Using CLI

```bash
pysparkle --help
pysparkle silver --help
pysparkle silver <service-principal-secret>
pysparkle gold --partitions 4
```

## Using an entrypoint script

```bash
python pysparkle_cli.py --help
python pysparkle_cli.py silver --help
python pysparkle_cli.py silver <service-principal-secret>
python pysparkle_cli.py gold --partitions 4
```

# Build
Use the following command to build a Python wheel (by default saved to `dist` directory).

```bash
poetry build
```

# Install
Please replace the version as required.

```bash
pip install dist/pysparkle-0.1.1-py3-none-any.whl
```

# Prerequisites
Spark runs on Java 8/11/17, Java 8 prior to version 8u362 support is deprecated
as of Spark 3.4.0. For details see: https://spark.apache.org/docs/latest/.

# Local testing
The current setup of PySparkle doesn't include the required libraries to connect
to Azure Data Lake Storage (they are pre-installed and configured in Azure Databricks
environment. To run the application locally, appropriate jar files would have to be
included in the classpath.

# Azure Data Factory setup
Example setup for running PySparkle from ADF. The pipeline below consists of two steps:
1. Get Service Principal Secret from Key Vault
2. Run Databricks Python activity with Service Principal Secret passed as a parameter.

```json
{
    "name": "silver",
    "properties": {
        "activities": [
            {
                "name": "Silver",
                "type": "DatabricksSparkPython",
                "dependsOn": [
                    {
                        "activity": "ServicePrincipal",
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
                    "secureInput": true
                },
                "userProperties": [],
                "typeProperties": {
                    "pythonFile": "dbfs:/FileStore/scripts/pysparkle_cli.py",
                    "parameters": [
                        "silver",
                        "@activity('ServicePrincipal').output.value"
                    ],
                    "libraries": [
                        {
                            "whl": "dbfs:/FileStore/jars/9976ba75_967d_41c5_a634_e0d86d7ef4ce/pysparkle-0.1.1-py3-none-any.whl"
                        }
                    ]
                },
                "linkedServiceName": {
                    "referenceName": "AzureDatabricks",
                    "type": "LinkedServiceReference"
                }
            },
            {
                "name": "ServicePrincipal",
                "type": "WebActivity",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": true,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "url": "https://amidostacksdeveuwde.vault.azure.net/secrets/service-principal-secret?api-version=7.0",
                    "method": "GET",
                    "authentication": {
                        "type": "MSI",
                        "resource": "https://vault.azure.net"
                    }
                }
            }
        ],
        "folder": {
            "name": "Process"
        },
        "annotations": []
    }
}
```
