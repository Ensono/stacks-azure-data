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
├── build # Resources for building and deploying the solution (ADO pipelines)
├── config # Config files which will be uploaded to blob storage and used by ETL processes (JSON)
│   ├── schemas # JSON schemas for config files
├── data_factory # Azure Data Factory resources
│   ├── adf_managed # Path is managed by development Azure Data Factory - JSON configuration
│   ├── deployment # Utilities for deploying Azure Data Factory resources
├── docs # Documentation
├── infra # TF modules to deploy core Azure resources
├── tests #
│   ├── e2e # End-to-end tests (pytest, behave)
│   ├── integration # Integration tests (pytest, behave)
|   ├── unit # Unit tests (pytest)
├── utils # Utilities module to be used across solution
├── .flake8 # Configuration for Flake8 linting
├── .pre-commit-config.yaml # Configuration for pre-commit
├── Makefile # Includes commands for environment setup
├── pyproject.toml # Configuration for Poetry, Black
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