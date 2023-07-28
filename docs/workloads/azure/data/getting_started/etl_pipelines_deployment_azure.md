---
id: etl_pipelines_deployment_azure
title: ETL Pipeline Deployment
sidebar_label: ETL Pipeline Deployment
hide_title: false
hide_table_of_contents: false
description: Data pipelines development & deployment
keywords:
  - datastacks
  - data
  - python
  - etl
  - cli
  - azure
  - template
---
---

This section provides an overview of generating a new ETL ingest pipeline / data engineering workload and deploying it into a Stacks Data Platform, using the [Datastacks](../etl_pipelines/datastacks.md) utility.
This aligns to the workflow shown in the [deployment architecture](../architecture/deployment_arch_data_azure.md#data-engineering-workloads) section.
It assumes all prerequisites are in place, including:
* A [deployed Stacks data platform](core_data_platform_deployment_azure.md)
* [Development environment set up](dev_quickstart_data_azure.md)

This process will deploy the following resources into the project:
 * Azure Data Factory resources (defined in Terraform / ARM)
   - Linked service
   - Dataset
   - Pipeline
 * Data ingest config files (JSON)
 * Azure DevOps CI/CD pipeline (YAML)
 * (optional) Spark jobs for data quality tests (Python)
 * Template unit tests (Python)
 * Template end-to-end tests (Python, Behave)

## Create feature branch

Before creating a new workload using Datastacks, open the project locally and create a new branch for the workload being created, e.g.:

```bash
git checkout -b feat/my-new-data-pipeline
```

## Prepare the Datastacks config file

Datastacks requires a config file for generating a new ingest workload. This config file should be a yaml file. A sample config file is included in the [de_templates](https://github.com/amido/stacks-azure-data/tree/main/de_templates) folder.

Using the sample config file as a starting point, create a new config file and populate the values relevant to your new ingest pipeline, e.g.

```yaml
# `dataset_name` parameter is used to determine names of the following ADF resources:
# - pipeline: Ingest_<dataset_name>
# - dataset: ds_<dataset_name>
# - linked service: ls_<dataset_name>
dataset_name: AzureSql_MyNewExample
pipeline_description: "Ingest from demo Azure SQL database using ingest config file."
data_source_type: azure_sql

key_vault_linked_service_name: ls_KeyVault
data_source_password_key_vault_secret_name: sql-password
data_source_connection_string_variable_name: sql_connection

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
```

## Generate project artifacts using Datastacks

Use the Datastacks CLI to generate the artifacts for the new workload, using the prepared config file (replacing `path_to_config_file/my_config.yaml` with the appropriate path). Note, a workload with Data Quality steps requires a data platform with a Databricks workspace:

```bash
# Initiate Datastacks using poetry:
poetry run datastacks

# Generate resources for an ingest pipeline (without data Quality steps)
datastacks generate ingest --config="path_to_config_file/my_config.yaml"

# Generate resources for an ingest pipeline with added Data Quality steps
datastacks generate ingest --config="path_to_config_file/my_config.yaml" --data-quality
```

This should add new project artifacts for the workload under `de_workloads/ingest`, based on the ingest workload templates. Review the resources that have been generated.

Once reviewed, commit the resources and push the branch to the remote project repository.

## Deploy new workload in non-prod environment

The generated workload will contain a YAML file containing a template Azure DevOps CI/CD pipeline for the workload, named `de-ingest-ado-pipeline.yaml`. Go to the Azure DevOps project Pipelines for the platform, and add a new pipeline, based on this file in your feature branch.

Running this pipeline in Azure DevOps will deploy the artifacts into the non-prod environment and run tests. If successful, the generated resources will now be available in the non-prod Stacks environment.

Continue to make any further amendments required to the new workload - for example:
* Update the (`ingest_config`) file with details of the data required from the new data source
* (If including DQ) update the (`ingest_dq`) file with details of data quality checks required on the data
* Update end-to-end tests, to ensure test coverage of the new data pipeline

## Deploy new workload in further environments

It is recommended in any Stacks data platform, that processes for deploying and releasing to further should be agreed and documented - ensuring sufficient review and quality assurance of any new workloads. The template CI/CD pipelines provided are based upon two platform environments (non-prod and prod) - but these may be amended depending upon the specific requirements of your project.
