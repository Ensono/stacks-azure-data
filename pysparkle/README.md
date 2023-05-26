# PySparkle Usage

## Using CLI

```bash
pysparkle --help
pysparkle silver --help
pysparkle silver --partitions 4
pysparkle gold
```

## Using an entrypoint script

```bash
python pysparkle_cli.py --help
python pysparkle_cli.py silver --help
python pysparkle_cli.py silver --partitions 4
python pysparkle_cli.py gold
```

# Build
Use the following command to build a Python wheel (by default saved to `dist` directory).

```bash
poetry build
```

# Install
Please replace the version as required.

```bash
pip install dist/pysparkle-0.1.0-py3-none-any.whl
```

# Prerequisites
Spark runs on Java 8/11/17, Java 8 prior to version 8u362 support is deprecated
as of Spark 3.4.0. For details see: https://spark.apache.org/docs/latest/.

# Azure Data Factory setup
Example setup for running PySparkle from ADF:

```json
{
    "name": "pysparkle_silver",
    "type": "DatabricksSparkPython",
    "dependsOn": [],
    "policy": {
        "timeout": "0.12:00:00",
        "retry": 0,
        "retryIntervalInSeconds": 30,
        "secureOutput": false,
        "secureInput": false
    },
    "userProperties": [],
    "typeProperties": {
        "pythonFile": "dbfs:/FileStore/scripts/pysparkle_cli.py",
        "parameters": [
            "silver",
            "--partitions=10"
        ],
        "libraries": [
            {
                "whl": "dbfs:/FileStore/jars/21ab01f3_390d_4a7c_9f28_384350b12219/pysparkle-0.1.0-py3-none-any.whl"
            }
        ]
    },
    "linkedServiceName": {
        "referenceName": "motyl-databricks",
        "type": "LinkedServiceReference"
    }
}
```
