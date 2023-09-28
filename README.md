# Stacks Azure Data Platform

Link to the official documentation:
[Stacks Azure Data Platform](https://stacks.ensono.com/docs/workloads/azure/data/intro_data_azure).

## Overview

The Ensono Stacks Azure Data Platform solution provides a framework for accelerating the deployment of a production-ready modern data platform in Azure.

![Stacks Data Overview](docs/workloads/azure/data/images/stacks-data-overview.png)

1. Use the [Stacks CLI](https://stacks.ensono.com/docs/stackscli/about) to generate a new data platform project.
2. Build and deploy the data platform infrastructure into your Azure environment.
3. Accelerate development of data workloads and ETL pipelines with [Datastacks](https://stacks.ensono.com/docs/workloads/azure/data/etl_pipelines/datastacks).

The Ensono Stacks Data Platform delivers a modern Lakehouse solution, based upon the [Medallion Architecture](etl_pipelines/etl_intro_data_azure.md#medallion-architecture), with Bronze, Silver and Gold layers for various stages of data preparation. The platform utilises tools including **Azure Data Factory** for data ingestion and orchestration, **Databricks** for data processing and **Azure Data Lake Storage Gen2** for data lake storage.

Key elements of the solution include:

- Infrastructure as code (IaC) for all infrastructure components (Terraform).
- Deployment pipelines to enable CI/CD and DataOps for the platform and all data workloads.
- [Datastacks](./etl_pipelines/datastacks.md) - a library and CLI built to accelerate the development of data engineering
workloads in the data platform.
- A framework for [data quality validations](./etl_pipelines/data_quality_azure.md).
- [Automated tests](./etl_pipelines/testing_data_azure.md) to ensure quality assurance and operational efficiency.
- Sample [data ingest pipelines](./etl_pipelines/ingest_data_azure.md) that transfer data from a source into the landing (Bronze) data lake zone.
- Sample [data processing pipelines](./etl_pipelines/data_processing.md) performing data transformations from Bronze to Silver and Silver to Gold layers.

### High-level architecture

![High-level architecture](docs/workloads/azure/data/images/Stacks_Azure_Data_Platform-HLD.png)

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
├── stacks-cli      # Example config to use when scaffolding a project using stacks-cli
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

Please refer to the documentation for getting started with developing Stacks:
[Local Development Quickstart](https://stacks.ensono.com/docs/workloads/azure/data/getting_started/dev_quickstart_data_azure).
