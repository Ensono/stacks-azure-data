# Stacks - Azure Data Platform solution

## Overview

Housing an Azure data platform solution template, this repository leverages **Azure Data Factory**
for data ingestion and orchestration of data processing using **Databricks**. It also employs
**Azure Data Lake Storage Gen2** for data lake storage. The solution's data workload naming
convention originates from Databricks' Medallion Architecture, a system emphasizing structured data
transformation layers. Key elements of the solution include:
* Infrastructure as code for all infrastructure components (Terraform & ARM Templates);
* Azure Data Factory resources and a sample ingest pipeline that transfers data from a sample source
into a landing (Bronze) data lake zone;
* Sample data processing pipelines named Silver and Gold. These are responsible for data
transformations from Bronze to Silver layer and from Silver to Gold layer, respectively;
* Data Quality validations;
* Deployment pipelines to enable CI/CD and DataOps for all components;
* Automated tests to ensure quality assurance and operational efficiency.

### High-level architecture

![High-level architecture](docs/workloads/azure/data/images/Stacks_Azure_Data_Platform-HLD.png?raw=true "High-level architecture")

### Infrastructure deployed
* Resource Group
* Azure Data Factory
* Azure Data Lake Storage Gen2
* Azure Blob Storage (for config files)
* Azure Key Vault
* Log Analytics Workspace
* Databricks Workspace
  * Azure Key Vault-backed secret scope

## Repository structure
```
stacks-azure-data
├── build # Azure DevOps pipelines configuration for building and deploying the core infrastructure
├── data_processing # Azure Data Factory ETL pipelines, leveraging Databricks for data transformations
│   ├── config # Configuration files (uploaded to blob storage)
│   ├── jobs # Data processing pipelines with optional Data Quality checks
│   │   ├── gold # Bronze to Silver layer transformations 
│   │   ├── silver # Silver to Gold layer transformations
├── de_build # Azure DevOps pipelines configuration for building and deploying ADF pipelines
├── deploy # TF modules to deploy core Azure resources (used by `build` directory)
├── docs # Documentation
├── ingest # Pipeline utilizing ADF for data ingestion, with optional Data Quality checks performed in Databricks
│   ├── config # Configuration files used by ETL and DQ processes (uploaded to blob storage)
│   ├── jobs
│   │   ├── Generate_Ingest_Query # Helper utility used in the ingestion pipeline
│   │   ├── Get_Ingest_Config # Helper utility used in the ingestion pipeline
│   │   ├── Ingest_AzureSql_Example # Data ingestion pipeline with optional Data Quality checks
├── pysparkle # Python library built to streamline data processing; packaged and uploaded to DBFS
├── utils # Python utilities package used across solution for local testing
├── .flake8 # Configuration for Flake8 linting
├── .pre-commit-config.yaml # Configuration for pre-commit hooks
├── Makefile # Includes commands for environment setup
├── pyproject.toml # Project dependecies
└── README.md # This file.
```

## Developing the solution

### Pre-requisites

* Python 3.10
* Poetry https://python-poetry.org/docs/
* (Windows users) A Linux distribution, e.g. WSL2 https://docs.microsoft.com/en-us/windows/wsl/install

### Setup Environment
Install the applications listed above, and ensure Poetry is added to your `$PATH`.

A Makefile has been created to assist with setting up the development environment. Run:
```bash
make setup_dev_environment
```

To install packages within Poetry, use (this will add the dependency to `pyproject.toml`):
```bash
poetry add packagename
```
to install a package for use only in the dev environment, use:
```bash
poetry add packagename --group dev
```

### Running unit tests

In order to run unit tests run the following command:

```bash
make test
```

### Running E2E Tests

To run E2E tests locally you will need to login through the Azure CLI:

```bash
az login 
```

To set the correct subscription run:

```bash
az account set --subscription <name or id>
```

To run the E2E tests you need to set up the following environment variables.

- `SUBSCRIPTION_ID`
- `RESOURCE_GROUP_NAME`
- `DATA_FACTORY_NAME`
- `REGION_NAME`
- `STORAGE_ACCOUNT_NAME`

The E2E tests may require additional permissions as we are editing data in ADLS during the E2E tests. If the tests fail
whilst clearing up directories please check you have the necessary permissions to read, write and execute against ADLS.

To run the E2E tests run:

```bash
make test_e2e
```