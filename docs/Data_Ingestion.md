# Data Ingestion

The solution contains a sample Azure Data Factory pipeline for ingesting data from a sample data source (Azure SQL) and loading data into the data lake 'landing' zone.

## Pipeline overview

The diagram below gives an overview of the ingestion pipeline design.

![ADF Pipeline Design](images/ADF_PipelineDesign.png?raw=true "ADF Pipeline Design")

## Configuration

The ingest process is designed around reusable pipelines which are metadata-driven. This means once an initial data pipeline is created for a given data source, additional entities from the same data source can be added or modified just by updating a configuration file. These config files are stored in the [config](../config/) directory.

JSON format is used for the config files. A common schema is to be used for all data ingest sources - an example is provided of a [config file](../config/ingest_sources/example_azuresql_1.json) and its [schema](../config/ingest_sources/schema/ingest_config_schema.json).

All data ingest sources are expected to have the same JSON keys, except for under `ingest_entities`, where different keys will be required dependent on the data source type (the example provided are the keys required for a SQL database source). [Tests](../tests/unit/test_config.py) are provided to ensure the config files remain valid against the schema. See the descriptions of the example JSON config file below:

```
{
    "data_source_name": "example_azuresql_1",  # Identifier of the data source - must be unique
    "data_source_type": "azure_sql",           # Data source type
    "enabled": true,                           # Boolean flag to enable / disable the data source from being ingested
    "ingest_entities": [                       # Array of entities to be ingested from the source
        {
            "version": 1,                      # Version number - increment this if the entitiy's schema changes
            "display_name": "SalesLT.Product", # Name to identify the entity - must be unique per data source
            "enabled": true,                   # Boolean flag to enable / disable the entity from being ingested
            "schema": "SalesLT",               # (SQL sources only) Database schema
            "table": "Product",                # (SQL sources only) Database table
            "columns": "*",                    # (SQL sources only) Columns to select
            "load_type": "delta",               # (SQL sources only) Full or delta load. If delta load selected, then also include the following keys
            "delta_date_column": "ModifiedDate",         # (SQL sources only, delta load) Date column to use for filtering the date range
            "delta_upsert_key": "SalesOrderID"           # (SQL sources only, delta load) Primary key for determining updated columns in a delta load
        }
    ]
}

```

These config files will be loaded in for a given data source every time an ingestion pipeline is triggered in Data Factory, and all entities will be ingested. To disable a particular ingest source or entitiy without removing it, you can set `"enabled": false` - these will be ignored by the Data Factory pipeline.

### Data Factory pipeline design
The sample pipelines provided give an example of a data ingest process from source to data lake. The pipelines folder is structured as follows:

![ADF Pipelines](images/ADF_PipelinesList.png?raw=true "ADF Pipelines")

* `Ingest` contains ingest pipelines specific to the given data source. These are the parent pipelines that would be triggered on a recurring basis to ingest from a data source.
* The pipelines within `Utilities` are reusable pipelines, referenced by other pipelines. This would not be triggered independently.

The `ingest_azure_sql_demo` pipeline consists of the following steps:

![ADF Ingest Pipeline](images/ADF_IngestPipeline.png?raw=true "ADF Ingest Pipeline")

1. Step 1: Call the utility pipeline `get_ingest_config`, passing the data source name as a parameter. This will return the config data required for the given data source.
2. Step 2: Loop through each ingest entity:
   * Generate an SQL query the extract the required values and range of data, based on the provided config values (for example, delta queries will contain a `WHERE` clause to restrict the date range loaded)
   * Execute the SQL query against the data source, and copy the results to Data Lake storage landing container in the appropriate path (data is validated using ADFs inbuilt data validation capability).
