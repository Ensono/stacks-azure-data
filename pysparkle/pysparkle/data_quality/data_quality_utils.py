"""
Data_quality utility functions to set up validations
"""
from typing import List, Dict
from pyspark.sql import DataFrame

from great_expectations.core.batch import RuntimeBatchRequest
from great_expectations.core.expectation_configuration import ExpectationConfiguration
from great_expectations.core.expectation_validation_result import (
    ExpectationSuiteValidationResult,
)
from great_expectations.core.expectation_suite import ExpectationSuite
from great_expectations.data_context import BaseDataContext
from great_expectations.data_context.types.base import (
    DataContextConfig,
    FilesystemStoreBackendDefaults,
)


def create_datasource_context(datasource_name: str, gx_directory_path: str) -> BaseDataContext:
    """
    Given a string containing the datasource name, this function generates a data context instance

    Args:
        datasource_name: Name of the datasource to be validated
        gx_directory_path: directory to store details of the gx context 

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

    context = BaseDataContext(project_config=data_context_config)

    context.add_datasource(**datasource_config)

    return context


def add_expectations_for_columns(
    expectation_suite: ExpectationSuite,
    validation_conf: Dict,
) -> ExpectationSuite:
    """
    Add expectations for columns as defined in the config file.

    Args:
        expectation_suite: Existing expectation suite to be added to
        validation_conf: dict containing details of validators to be added to columns

    Returns:
        Expectation suite with new expectations saved
    """

    for column in validation_conf:
        column_name = column["column_name"]
        for expectation in column["expectations"]:
            expectation_suite.add_expectation(
                ExpectationConfiguration(
                    expectation_type=expectation["expectation_type"],
                    kwargs={
                        **{"column": column_name},
                        **expectation["expectation_kwargs"],
                    },
                )
            )

    return expectation_suite


def create_expectation_suite(
    context: BaseDataContext,
    dq_conf: Dict,
) -> BaseDataContext:
    """
    Creates an expectation suite, and adds expectations to it

    Args:
        context: Existing expectation suite to be added to
        dq_conf: dict containing details of validators to be added to column

    Returns:
        Data context with expectations suite added
    """
    expectation_suite = context.create_expectation_suite(
        expectation_suite_name=dq_conf["expectation_suite_name"],
        overwrite_existing=True,
    )
    expectation_suite = add_expectations_for_columns(
        expectation_suite, dq_conf["validation_config"]
    )
    context.save_expectation_suite(expectation_suite)

    return context


def execute_validations(
    context: BaseDataContext,
    dq_conf: Dict,
    df: DataFrame,
) -> ExpectationSuiteValidationResult:
    """
    Given a Great Expectations data context, the relevant config, and a dataframe containing the
    data to be validated, this function runs the validations and returns the result

    Args:
        context: Great Expectations data context object
        dq_conf: Dict containing the required config for validation
        df: Dataframe to be validated

    Returns:
        Validation Result for the applied expectation suite
    """
    batch_request = RuntimeBatchRequest(
        datasource_name=f"{dq_conf['datasource_name']}",
        data_connector_name=f"{dq_conf['datasource_name']}_data_connector",
        data_asset_name=f"{dq_conf['datasource_name']}",
        batch_identifiers={
            "batch_name": "latest_batch",
        },
        runtime_parameters={"batch_data": df},
    )
    validator = context.get_validator(
        batch_request=batch_request,
        expectation_suite_name=dq_conf["expectation_suite_name"],
    )
    gx_validation_results = validator.validate()

    return gx_validation_results
