# Stacks - Azure Data Ingest solution

## Overview

This repository contains a template for an Azure data platform ingest solution, based around Azure Data Factory, to be used as a 'bronze' or 'landing' data lake zone.

### Infrastructure deployed
* Resource Group
* Azure Data Factory
* Azure Data Lake Storage Gen2
* Azure Blob Storage (for config files)
* Azure Key Vault
* Log Analytics Workspace

## Repository structure
```
stacks-azure-data-ingest
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
In order to work on the project, developers require:

* Python 3.10
* Poetry https://python-poetry.org/docs/
* (Windows users) A Linux distribution, e.g. WSL2 https://docs.microsoft.com/en-us/windows/wsl/install

### Setup Environment
Install the applications listed above, and ensure Poetry is added to  your `$PATH`.

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
