"""Data quality utility functions to set up validations."""
from datetime import date

import great_expectations as gx
from great_expectations.core.batch import RuntimeBatchRequest
from great_expectations.core.expectation_configuration import ExpectationConfiguration
from great_expectations.core.expectation_suite import ExpectationSuite
from great_expectations.core.expectation_validation_result import (
    ExpectationSuiteValidationResult,
)
from great_expectations.data_context import AbstractDataContext
from great_expectations.data_context.types.base import (
    DataContextConfig,
    FilesystemStoreBackendDefaults,
)
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql.types import StringType, StructField, StructType, DateType, BooleanType

from pysparkle.data_quality.config import DatasourceConfig, ValidationConfig
from pysparkle.pyspark_utils import save_dataframe_as_delta


def create_datasource_context(datasource_name: str, gx_directory_path: str) -> AbstractDataContext:
    """Given a string containing the datasource name, this function generates a data context instance.

    Args:
        datasource_name: Name of the datasource to be validated
        gx_directory_path: Directory to store details of the gx context.

    Returns:
        Populated data context instance to which expectations can be added
    """
    datasource_config = {
        "name": f"{datasource_name}",
        "class_name": "Datasource",
        "module_name": "great_expectations.datasource",
        "execution_engine": {
            "module_name": "great_expectations.execution_engine",
            "class_name": "SparkDFExecutionEngine",
        },
        "data_connectors": {
            f"{datasource_name}_data_connector": {
                "module_name": "great_expectations.datasource.data_connector",
                "class_name": "RuntimeDataConnector",
                "batch_identifiers": [
                    "batch_name",
                ],
            },
        },
    }

    root_directory = f"{gx_directory_path}/{datasource_name}/"

    data_context_config = DataContextConfig(
        store_backend_defaults=FilesystemStoreBackendDefaults(root_directory=root_directory),
    )

    context = gx.get_context(project_config=data_context_config)

    context.add_datasource(**datasource_config)

    return context


def add_expectations_for_columns(
    expectation_suite: ExpectationSuite,
    validation_conf: list[ValidationConfig],
) -> ExpectationSuite:
    """Add expectations for columns as defined in the config file.

    Args:
        expectation_suite: Existing expectation suite to be added to.
        validation_conf: List of validators to be added to columns.

    Returns:
        Expectation suite with new expectations saved.
    """
    for column in validation_conf:
        column_name = column.column_name
        for expectation in column.expectations:
            expectation_suite.add_expectation(
                ExpectationConfiguration(
                    expectation_type=expectation.expectation_type,
                    kwargs={
                        **{"column": column_name},
                        **expectation.expectation_kwargs,
                    },
                )
            )

    return expectation_suite


def add_expectation_suite(
    context: AbstractDataContext,
    dq_conf: DatasourceConfig,
) -> AbstractDataContext:
    """Creates an expectation suite and adds expectations to it.

    Args:
        context: Existing expectation suite to be added to.
        dq_conf: Details of validators to be added to column.

    Returns:
        Data context with expectations suite added.
    """
    expectation_suite = context.add_or_update_expectation_suite(expectation_suite_name=dq_conf.expectation_suite_name)

    expectation_suite = add_expectations_for_columns(expectation_suite, dq_conf.validation_config)
    context.update_expectation_suite(expectation_suite)

    return context


def execute_validations(
    context: AbstractDataContext,
    dq_conf: DatasourceConfig,
    df: DataFrame,
) -> ExpectationSuiteValidationResult:
    """Execute Great Expectations validations.

    Given a Great Expectations data context, the relevant config, and a dataframe containing the
    data to be validated, this function runs the validations and returns the result.

    Args:
        context: Great Expectations data context object.
        dq_conf: The required configuration for validation.
        df: Dataframe to be validated.

    Returns:
        Validation Result for the applied expectation suite.
    """
    batch_request = RuntimeBatchRequest(
        datasource_name=f"{dq_conf.datasource_name}",
        data_connector_name=f"{dq_conf.datasource_name}_data_connector",
        data_asset_name=f"{dq_conf.datasource_name}",
        batch_identifiers={
            "batch_name": "latest_batch",
        },
        runtime_parameters={"batch_data": df},
    )
    validator = context.get_validator(
        batch_request=batch_request,
        expectation_suite_name=dq_conf.expectation_suite_name,
    )
    gx_validation_results = validator.validate()

    return gx_validation_results


def publish_quality_results_table(
    spark: SparkSession, dq_path: str, datasource_name: str, results: list, data_quality_run_date: date
) -> DataFrame:
    """Publish data quality results to table.

    Given a ValidatorResults object, this function
    writes out the validation results for a given date
    and datasource in a table and returns any failing validations

    Args:
        spark: Spark session.
        dq_path: File path to write the results table to
        datasource_name: Name of the datasource to be validated
        results: List containing validator results from great expectations
        data_quality_run_date: Date that the validations were executed

    Returns:
        Dataframe containing failed validations
    """
    dq_results_schema = StructType(
        [
            StructField("data_quality_run_date", DateType(), True),
            StructField("datasource_name", StringType(), True),
            StructField("column_name", StringType(), True),
            StructField("validator", StringType(), True),
            StructField("value_set", StringType(), True),
            StructField("threshold", StringType(), True),
            StructField("failure_count", StringType(), True),
            StructField("failure_percent", StringType(), True),
            StructField("success", BooleanType(), True),
        ]
    )

    emp_RDD = spark.sparkContext.emptyRDD()

    data = spark.createDataFrame(data=emp_RDD, schema=dq_results_schema)

    for result in results:
        try:
            Column = result.expectation_config.kwargs["column"]
        except KeyError:
            Column = result.expectation_config.kwargs["column_A"]
        Validator = result.expectation_config.expectation_type
        try:
            Value_set = result.expectation_config.kwargs["value_set"]
        except KeyError:
            Value_set = None
        try:
            Threshold = result.expectation_config.kwargs["mostly"]
        except KeyError:
            Threshold = None
        Unexpected_count = result.result["unexpected_count"]
        Unexpected_percent = result.result["unexpected_percent"]
        Success = result["success"]
        row = spark.createDataFrame(
            data=[
                [
                    data_quality_run_date,
                    datasource_name,
                    Column,
                    Validator,
                    Value_set,
                    Threshold,
                    Unexpected_count,
                    Unexpected_percent,
                    Success,
                ]
            ],
            schema=dq_results_schema,
        )
        data = data.union(row)

    data = data.coalesce(1)

    save_dataframe_as_delta(spark, data, dq_path, overwrite=False, merge_keys=["data_quality_run_date"])

    failed_validations = data.filter(data.Success is False)
    return failed_validations
