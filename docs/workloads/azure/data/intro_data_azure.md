---
id: intro_data_azure
title: Architecture Overview
sidebar_label: Architecture Overview
hide_title: true
hide_table_of_contents: false
description: Azure Data Platform - Architecture Overview
keywords:
  - data
  - python
  - etl
  - databricks
  - azure
  - adf
---

# Stacks – Azure Data Platform

## Overview

Housing an Azure data platform template, [stacks-azure-data](https://github.com/amido/stacks-azure-data)
repository leverages **Azure Data Factory** for data ingestion and orchestration of data processing
using **Databricks**. It also employs **Azure Data Lake Storage Gen2** for data lake storage.
The solution's data workload naming convention originates from Databricks' Medallion Architecture,
a system emphasizing structured data transformation layers. Key elements of the solution include:

* Infrastructure as code (IaC) for all infrastructure components (Terraform & ARM Templates);
* Azure Data Factory (ADF) resources and a sample ingest pipeline that transfers data from a sample
source into a landing (Bronze) data lake zone;
* Sample data processing pipelines named Silver and Gold. These are responsible for data
transformations from 'Bronze to Silver' layer and from 'Silver to Gold' layer, respectively;
* Data Quality validations;
* Deployment pipelines to enable CI/CD and DataOps for all components;
* Automated tests to ensure quality assurance and operational efficiency.

### High-level architecture

![High-level architecture](images/Stacks_Azure_Data_Platform-HLD.png?raw=true)

### Infrastructure deployed
* Resource Group
* Azure Data Factory
* Azure Data Lake Storage Gen2
* Azure Blob Storage (for config files)
* Azure Key Vault
* Log Analytics Workspace
* Databricks Workspace
  * Azure Key Vault-backed secret scope
