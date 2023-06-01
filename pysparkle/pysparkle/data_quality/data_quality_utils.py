"""
Data_quality utility functions to set up validations
"""
from typing import List, Dict

from great_expectations.core.batch import RuntimeBatchRequest
from great_expectations.core.expectation_configuration import (
    ExpectationConfiguration)
from great_expectations.core.expectation_suite import ExpectationSuite
from great_expectations.data_context import BaseDataContext
from great_expectations.data_context.types.base import DataContextConfig, \
    FilesystemStoreBackendDefaults


def create_datasource_config(datasource_name: str, suite_name: str) -> Dict:
    """
    Given a string containing the datasource name, this function generates a dict
    containing the datasource config

    Args:
        datasource_name (str): Name of the datasource to be validated

    Returns:
        Dict: populated datasource config dictionary to be used to initialise great expectations
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
                ]
            },
        },
    }

    root_directory = f"/dbfs/great_expectations/{datasource_name}/"

    data_context_config = DataContextConfig(
        store_backend_defaults=FilesystemStoreBackendDefaults(
            root_directory=root_directory
        ),
    )

    context = BaseDataContext(project_config=data_context_config)

    context.add_datasource(**datasource_config)

    return context

def add_expectations_for_column(
    expectation_suite: ExpectationSuite,
    validation_conf: Dict,
) -> ExpectationSuite:
    """Add expectations for a list of columns.
    
        Args:
        expectation_suite (ExpectationSuite): Existing expectation suite to be added to
        columns (List[str]): List of column names to add expectations to
        expectation_type (str): expectation name
        expectation_kwargs (dict): additional kwargs to be passed to the expectation 

    Returns:
        validator: great_expectations validator instance ready for expectations to be added
    """

    for column in validation_conf:
        column_name = column["column_name"]
        for expectation in column["expectations"]:
            expectation_suite.add_expectation(
                ExpectationConfiguration(
                    expectation_type=expectation["expectation_type"],
                    kwargs={**{"column": column_name}, **expectation["expectation_kwargs"]}
                )
            )            
    
    return expectation_suite

def create_expectation_suite(
    context,
    DQ_conf,
):
    expectation_suite = context.create_expectation_suite(
        expectation_suite_name=DQ_conf["expectation_suite_name"], overwrite_existing=True
    )
    expectation_suite = add_expectations_for_column(
        expectation_suite,
        DQ_conf["validation_config"]
    )
    context.save_expectation_suite(expectation_suite)

    return context

def execute_validations(context, DQ_conf, df):
    batch_request = RuntimeBatchRequest(
        datasource_name=f"{DQ_conf['dataset_name']}",
        data_connector_name=f"{DQ_conf['dataset_name']}_data_connector",
        data_asset_name=f"{DQ_conf['dataset_name']}",
        batch_identifiers={
            "batch_name": "latest_batch",
        },
        runtime_parameters={"batch_data": df},
    )
    validator = context.get_validator(batch_request=batch_request,
                                    expectation_suite_name=DQ_conf['expectation_suite_name'])
    gx_validation_results = validator.validate()

    return gx_validation_results
