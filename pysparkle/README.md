# PySparkle Usage

> ℹ️ PySparkle Silver processing requires environment variable AZURE_CLIENT_SECRET
> (Service Principal Secret) to be set.

## Using CLI

```bash
pysparkle --help
pysparkle silver --help
pysparkle silver
pysparkle gold --partitions 4
```

## Using an entrypoint script

```bash
python pysparkle_cli.py --help
python pysparkle_cli.py silver --help
python pysparkle_cli.py silver
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

# Local execution
The current setup of PySparkle doesn't include the required libraries to connect
to Azure Data Lake Storage (they are pre-installed and configured in Azure Databricks
environment. To run the application locally, appropriate jar files would have to be
included in the Spark session (`spark.jars.packages` configuration parameter).

# Azure Data Factory setup
Example setup for running PySparkle from ADF.

```json
{
    "name": "silver",
    "properties": {
        "activities": [
            {
                "name": "Silver",
                "type": "DatabricksSparkPython",
                "dependsOn": [],
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
                        "silver"
                    ],
                    "libraries": [
                        {
                            "whl": "dbfs:/FileStore/jars/c64a5713_8fa5_4e3a_beda_218f9ab5730e/pysparkle-0.1.1-py3-none-any.whl"
                        }
                    ]
                },
                "linkedServiceName": {
                    "referenceName": "AzureDatabricks",
                    "type": "LinkedServiceReference"
                }
            }
        ],
        "folder": {
            "name": "Process"
        },
        "annotations": [],
        "lastPublishTime": "2023-05-29T17:16:07Z"
    },
    "type": "Microsoft.DataFactory/factories/pipelines"
}
```
