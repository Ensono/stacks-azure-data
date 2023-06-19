# Usage

```bash
pysparkle data-quality --help
pysparkle data-quality --config-path "data_quality/silver_dq.json"
```

`config-path` is a Path to a JSON config inside an Azure Blob container. The container name
for storing configurations is `config` and it is defined in the configuration set in the pysparkle
package.

Azure Blob storage account name is expected to be set in an environment variable as explained
in the main README file. 


# JSON Configuration File for Great Expectations
This section describes the structure of the JSON configuration file used in our system.
The configuration is defined using Python's Pydantic library for data validation.

Here is the description of the main elements:

1. `gx_directory_path`: Path to the Great Expectations metadata store.
2. `dataset_name`: Name of the dataset that is being processed.
3. `datasource_config`: List of datasource configurations where each configuration contains the following fields:
   - `datasource_name`: Name of the data asset, e.g., table or file name.
   - `datasource_type`: Source system type, e.g., table, parquet, csv. 
   - `data_location`: Path to the given data asset or a fully qualified table name.
   - `expectation_suite_name`: Name of the expectation suite associated with this data source.
   - `validation_config`: A list of validation configurations where each configuration contains the following fields:
     - `column_name`: Name of the validated column. 
     - `expectations`: List of expectations where each expectation has the following fields:
       - `expectation_type`: Name of the Great Expectations expectation class to use.
       - `expectation_kwargs`: The keyword arguments to pass to the expectation class.

## Examples
Here's a minimal example of a configuration file:
```json
{
    "gx_directory_path": "/dbfs/great_expectations/",
    "dataset_name": "movies_dataset",
    "datasource_config": [
        {
            "datasource_name": "movies_metadata",
            "datasource_type": "table",
            "data_location": "staging.movies_metadata",
            "expectation_suite_name": "movies_metadata_suite",
            "validation_config": [
                {
                    "column_name": "adult",
                    "expectations": [
                        {
                            "expectation_type": "expect_column_values_to_not_be_null",
                            "expectation_kwargs": {}
                        },
                        {
                            "expectation_type": "expect_column_values_to_be_of_type",
                            "expectation_kwargs": {"type_": "StringType"}
                        }
                    ]
                }
            ]
        }
    ]
}
```

### Data location for ADLS files
In order to validate data stored in ADLS, you need to provide the full path to a given data asset, e.g.:

`"data_location": "abfss://raw@{ADLS_ACCOUNT}.dfs.core.windows.net/example_azuresql_1/SalesLT.Product/v1/*/*/*"`

> ℹ️ It is possible to use environment variables as in the example above. Placeholders in the form
> {ENV_VAR_NAME} will be replaced with the corresponding environment variable values.
