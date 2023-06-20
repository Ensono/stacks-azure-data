# PySparkle Usage

> ℹ️ PySparkle Silver processing requires the following environment variables to be set
> to access Azure Data Lake Storage (ADLS):
> - AZURE_TENANT_ID - Directory ID for Azure Active Directory application,
> - AZURE_CLIENT_ID - Application ID for Azure Active Directory application,
> - AZURE_CLIENT_SECRET - Service Principal Secret,
> - ADLS_ACCOUNT - ADLS account name,
> - BLOB_ACCOUNT - Blob Storage account name.

## Using CLI

```bash
pysparkle --help
pysparkle silver --help
pysparkle silver --dataset-name=movies_dataset
pysparkle --log-level=warning silver --dataset-name=movies_dataset
pysparkle data-quality --config-path "data_quality/silver_dq.json"
```

## Using an entrypoint script

```bash
python pysparkle_cli.py --help
python pysparkle_cli.py silver --help
python pysparkle_cli.py silver --dataset-name=movies_dataset
python pysparkle_cli.py --log-level=warning silver --dataset-name=movies_dataset
python pysparkle_cli.py data-quality --config-path "data_quality/silver_dq.json"
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
                "policy": {},
                "userProperties": [],
                "typeProperties": {
                    "pythonFile": "dbfs:/FileStore/scripts/pysparkle_cli.py",
                    "parameters": [
                        "silver",
                        "--dataset-name=movies_dataset"
                    ],
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
        "folder": {
            "name": "Process"
        },
        "annotations": [],
        "lastPublishTime": "2023-05-29T17:16:07Z"
    },
    "type": "Microsoft.DataFactory/factories/pipelines"
}
```
