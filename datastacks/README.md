# Datastacks

[Datastacks](https://github.com/amido/stacks-azure-data/tree/main/Datastacks) is a Python library
built to support the Ensono Stacks Data Platform which can be used for various functions within the project.

At present the library works to ease usage of the templates within the [de_templates](https://github.com/amido/stacks-azure-data/tree/main/de_templates) directory, and provides a CLI which can be used to generate new components to be used within a data platform.

## Key components

The key components of datastacks currently include:

- **Generate**: This command contains subcommands which generate components for the data platform given a config file. 

  - **Ingest**: This command utilises the template for ingest data pipelines, and uses a given config file to generate the required code for a new ingest pipeline ready for use. A flag can be included to specify whether or not to include data quality components in the pipeline

### Using CLI

```bash
datastacks --help
datastacks generate --help
datastacks generate ingest --help
datastacks generate ingest --config-path="de_templates/test_config_ingest.yaml"
datastacks generate ingest --config-path="de_templates/test_config_ingest.yaml" --data-quality
```

### Using an entrypoint script

```bash
python datastacks_cli.py --help
python datastacks_cli.py generate --help
python datastacks_cli.py generate ingest --help
python datastacks_cli.py generate ingest --config-path="de_templates/test_config_ingest.yaml"
python datastacks_cli.py generate ingest --config-path="de_templates/test_config_ingest.yaml" --data-quality
```

## Required Config File

For component generation, the Datastacks cli take a path to a config file. This config file should be a yaml file and have the below format. A sample config file is included in the templates folder.

```yaml
# `dataset_name` parameter is used to determine names of the following ADF resources:
pipeline: Ingest_test
# - dataset: ds_<dataset_name>
# - linked service: ls_<dataset_name>
dataset_name: AzureSql_Example
pipeline_description: "Ingest from demo Azure SQL database using ingest config file."
data_source_type: azure_sql

key_vault_linked_service_name: ls_KeyVault
data_source_password_key_vault_secret_name: sql-password


# Azure DevOps configurations

ado_variable_groups_nonprod:
  - amido-stacks-de-pipeline-nonprod
  - amido-stacks-infra-credentials-nonprod
  - stacks-credentials-nonprod-kv

ado_variable_groups_prod:
  - amido-stacks-de-pipeline-prod
  - amido-stacks-infra-credentials-prod
  - stacks-credentials-prod-kv


# Datalake containers

bronze_container: raw
silver_container: staging
gold_container: curated


#######################
# Optional parameters #
#######################

# Deployment mode for terraform; if not set, the default is Incremental
default_arm_deployment_mode: Incremental

# Workload config; if not set, the default values are 2020-01-01 and 2020-01-31 resp.
# These are used to set the default time window in the pipeline and in the corresponding e2e tests
window_start_default: 2020-01-01
window_end_default: 2020-01-31
```
