# Stacks Azure Data Platform

Link to the official documentation:
[Stacks Azure Data Platform](https://stacks.amido.com/docs/workloads/azure/data/intro_data_azure).

## Overview

The Stacks Azure Data Platform solution provides
a framework for accelerating the deployment of a production-ready data platform.

![Stacks Data Overview](docs/workloads/azure/data/images/stacks-data-overview.png)

1. Use the [Stacks CLI](https://stacks.amido.com/docs/stackscli/about) to generate a new data platform project.
2. Build and deploy the data platform infrastructure into your Azure environment.
3. Accelerate development of data workloads and ETL pipelines with [Datastacks](https://stacks.amido.com/docs/workloads/azure/data/etl_pipelines/datastacks).

The Stacks Data Platform utilises tools including **Azure Data Factory** for data
ingestion and orchestration, **Databricks** for data processing and **Azure Data Lake Storage Gen2**
for data lake storage. The solution is based around a [medallion architecture](https://stacks.amido.com/docs/workloads/azure/data/etl_pipelines/etl_intro_data_azure#data-pipelines), with Bronze, Silver and Gold layers for various stages of data preparation.

Key elements of the solution include:

* Infrastructure as code (IaC) for all infrastructure components (Terraform).
* [Datastacks](https://stacks.amido.com/docs/workloads/azure/data/etl_pipelines/datastacks) - a library and CLI built to accelerate the development of data engineering
workloads in the data platform based upon templates.
* [Pysparkle](https://stacks.amido.com/docs/workloads/azure/data/etl_pipelines/pysparkle/pysparkle_quickstart) - a library built to streamline data processing activities running in Apache Spark.
* Sample ingest pipeline that transfers data from a source into a landing (Bronze) data lake zone.
* Sample data processing pipelines performing data transformations from Bronze to Silver and Silver to Gold layers.
* Data Quality validations.
* Deployment pipelines to enable CI/CD and DataOps for all components.
* Automated tests to ensure quality assurance and operational efficiency.

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
├── pysparkle       # Python library built to streamline data processing; packaged and uploaded to DBFS
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
[Local Development Quickstart](https://stacks.amido.com/docs/workloads/azure/data/getting_started/dev_quickstart_data_azure).
