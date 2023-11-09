# Gold Movies Example Workload

__Workload Name:__ gold_movies_example

__Workload Type:__ Processing

__Description:__ Example pipeline for generating gold layer movies data.

Created in Stacks Azure Data Platform. Contains resources for:

* [Data Factory resources](#Data-Factory-Resources)
* [Spark jobs](#Spark-Jobs)
* [Tests](#Tests)
* [CICD pipelines (Azure DevOps)](#Azure-DevOps-CICD-Pipeline)

## Data Factory Resources

Terraform is used to deploy the ARM template for the Data Factory pipeline.
```
data_factory
├── pipelines
│   └── arm_template.json
├── adf_pipelines.tf
├── constraints.tf
├── data.tf
├── provider.tf
└── vars.tf
```

## Spark Jobs

This Spark job is written in Python (PySpark) and uses the `stacks-data` library to process datasets produced by the `silver_movies_example` workload and produce a Gold layer dataset. Specifically, it loads the `ratings_small` dataset, calculates the average rating for each movie, and joins that to the `movies_metadata` dataset before outputting it as a new `movies_ratings_agg` dataset.

```
spark_jobs
├── __init__.py
└── process.py
```


## Tests

This workload contains a test suite for the Spark job, written in Pytest. The tests are run as part of the CICD pipeline (see [Azure DevOps CICD Pipelines](#Azure-DevOps-CICD-Pipeline)).

```
tests
├── end_to_end
│   └── __init__.py
├── unit
│   ├── conftest.py
│   ├── __init__.py
│   └── test_processing.py
└── __init__.py
```


## Azure DevOps CICD Pipeline

The CICD pipeline for this workload is defined in the `de-process-ado-pipeline.yml` file. It is triggered by a pull request to the `main` branch and will deploy and test the workload in NonProd.
Once the pull request is merged, the pipeline will be triggered again and will deploy and test the workload in Prod.
