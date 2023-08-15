# Stacks Azure Data Platform

Link to the official documentation:
[Stacks Azure Data Platform](https://stacks.amido.com/docs/workloads/azure/data/intro_data_azure).

## Overview

The Stacks Azure Data Platform solution provides a template for deploying a production-ready data
platform, including **Azure Data Factory** for data ingestion and orchestration, **Databricks** for
data processing and **Azure Data Lake Storage Gen2** for data lake storage. The solution's data
workload naming convention originates from Databricks' Medallion Architecture, a system emphasising
structured data transformation layers.

Key elements of the solution include:

* Infrastructure as code (IaC) for all infrastructure components (Terraform & ARM Templates);
* Azure Data Factory (ADF) resources and a sample ingest pipeline that transfers data from a sample
source into a landing (Bronze) data lake zone;
* Sample data processing pipelines named Silver and Gold. These are responsible for data transformations from
'Bronze to Silver' layer and from 'Silver to Gold' layer, respectively;
* Data Quality framework using Great Expectations;
* Deployment pipelines to enable CI/CD and DataOps for all components;
* Automated tests to ensure quality assurance and operational efficiency;
* [Datastacks](datastacks/README.md) - a library and CLI built to accelerate the development of data engineering
workloads in the data platform;
* [Pysparkle](pysparkle/README.md) - a library built to streamline data processing activities running in Apache Spark.

### High-level architecture

![High-level architecture.png](docs/workloads/azure/data/images/Stacks_Azure_Data_Platform-HLD.png)

### Infrastructure deployed

* Resource Group
* Key Vault
* Azure Data Lake Storage Gen2
* Azure Blob Storage
* Azure Data Factory
* Log Analytics Workspace
* Databricks Workspace (optional)
* Azure SQL Database (optional)

## Repository structure

```md
stacks-azure-data
├── build           # Deployment pipeline configuration for building and deploying the core infrastructure
├── datastacks      # Python library and CLI to accelerate the development of data engineering workloads
├── de_build        # Deployment pipeline configuration for building and deploying data engineering resources
├── de_templates    # Data engineering workload templates, including data pipelines, tests and deployment configuration
├── de_workloads    # Data engineering workload resources, including data pipelines, tests and deployment configuration
│   ├── data_processing         # Data processing and transformation workloads
│   ├── ingest                  # Data ingestion workloads
│   ├── shared_resources        # Shared resources used across data engineering workloads
├── deploy          # TF modules to deploy core Azure resources (used by `build` directory)
├── docs            # Documentation
├── pysparkle       # Python library built to streamline data processing; packaged and uploaded to DBFS
├── utils           # Python utilities package used across solution for local testing
├── .pre-commit-config.yaml         # Configuration for pre-commit hooks
├── Makefile        # Includes commands for environment setup
├── pyproject.toml  # Project dependencies
├── README.md       # This file
├── stackscli.yml   # Tells the Stacks CLI what operations to perform when the project is scaffolded
├── taskctl.yaml    # Controls the independent runner
└── yamllint.conf   # Linter configuration for YAML files used by the independent runner
```

## Developing the solution

### Pre-requisites

* Python 3.9+
* [Poetry](https://python-poetry.org/docs/)
* (Windows users) A Linux distribution, e.g. [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install)
* Java 8/11/17 as in the [Spark documentation](https://spark.apache.org/docs/latest/)

### Setup Environment

Install the applications listed above, and ensure Poetry is added to your `$PATH`.

A Makefile has been created to assist with setting up the development environment. Run:

```bash
make setup_dev_environment
```

#### Poetry basics
To install packages within Poetry, use (this will add the dependency to `pyproject.toml`):

```bash
poetry add packagename
```

To install a package for use only in the dev environment, use:

```bash
poetry add packagename --group dev
```

### Running unit tests

In order to run unit tests, run the following command:

```bash
make test
```

### Running E2E Tests

To run E2E tests locally, you will need to login through the Azure CLI:

```bash
az login
```

To set the correct subscription run:

```bash
az account set --subscription <name or id>
```

To run the E2E tests, you need to set up the following environment variables:

- `AZURE_SUBSCRIPTION_ID`
- `RESOURCE_GROUP_NAME`
- `DATA_FACTORY_NAME`
- `REGION_NAME`
- `AZURE_STORAGE_ACCOUNT_NAME`

The E2E tests may require additional permissions as we are editing data in ADLS during the E2E tests. If the tests fail
whilst clearing up directories please check you have the necessary permissions to read, write and execute against ADLS.

To run the E2E tests run:

```bash
make test_e2e
```
