import pytest

from datetime import date
from great_expectations.core.expectation_suite import ExpectationSuite
from great_expectations.core.expectation_validation_result import ExpectationValidationResult
from great_expectations.core.expectation_configuration import ExpectationConfiguration

from pysparkle.data_quality.utils import (
    add_expectations_for_columns,
    add_expectation_suite,
    execute_validations,
    publish_quality_results_table,
)


def test_create_datasource_context(dq_config, datasource_context):
    datasource_name = dq_config.datasource_config[0].datasource_name
    assert datasource_context.list_datasources()[0]["name"] == datasource_name
    assert (
        list(datasource_context.list_datasources()[0]["data_connectors"].keys())[0]
        == f"{datasource_name}_data_connector"
    )


def test_add_expectations_for_columns(dq_config):
    expectation_suite = ExpectationSuite(expectation_suite_name="test_suite")
    validation_config = dq_config.datasource_config[0].validation_config

    expectation_suite = add_expectations_for_columns(expectation_suite, validation_config)
    expectations = expectation_suite.expectations

    assert len(expectations) == 3
    assert expectations[0].expectation_type == "expect_column_values_to_not_be_null"
    assert expectations[0].kwargs["column"] == "test_column_1"
    assert expectations[1].expectation_type == "expect_column_values_to_be_of_type"
    assert expectations[1].kwargs["column"] == "test_column_1"
    assert expectations[1].kwargs["type_"] == "StringType"
    assert expectations[2].expectation_type == "expect_column_values_to_be_in_set"
    assert expectations[2].kwargs["column"] == "test_column_2"
    assert expectations[2].kwargs["value_set"] == [1, 2, 3]


def test_add_expectation_suite(dq_config, datasource_context):
    assert datasource_context.list_expectation_suite_names() == []

    context = add_expectation_suite(datasource_context, dq_config.datasource_config[0])
    expected_suite_name = dq_config.datasource_config[0].expectation_suite_name

    assert context.list_expectation_suite_names() == [expected_suite_name]

    expectation_suite = context.get_expectation_suite(expected_suite_name)
    expectations = expectation_suite.expectations

    test_suite = ExpectationSuite(expectation_suite_name="test_suite")
    test_config = dq_config.datasource_config[0].validation_config
    test_suite = add_expectations_for_columns(test_suite, test_config)
    test_expectations = test_suite.expectations
    assert test_expectations == expectations


@pytest.mark.parametrize(
    "data,expected",
    [
        ([("test_1", 1), ("test_2", 2), ("test_3", 3), ("test_4", 1)], True),
        ([("test_1", 1), ("test_2", 2), ("test_3", 3), ("test_4", 4)], False),
        ([("test_1", 1), (None, 2)], False),
        ([(123, 1), (234, 2), (345, 3)], False),
    ],
)
def test_execute_validations(spark, dq_config, datasource_context, data, expected):
    df = spark.createDataFrame(data, ["test_column_1", "test_column_2"])

    context = add_expectation_suite(datasource_context, dq_config.datasource_config[0])
    result = execute_validations(context, dq_config.datasource_config[0], df)
    assert result["success"] is expected


@pytest.fixture(scope="session")
def expectation_results():
    result1 = {
        "element_count": 5,
        "unexpected_count": 0,
        "unexpected_percent": 0,
        "partial_unexpected_list": [],
        "missing_count": 0,
        "missing_percent": 0.0,
        "unexpected_percent_total": 0,
        "unexpected_percent_nonmissing": 0,
        "partial_unexpected_index_list": None,
        "partial_unexpected_counts": [],
        "unexpected_list": [],
        "unexpected_index_list": None,
    }
    kwargs1 = {"column": "col2", "result_format": "COMPLETE", "batch_id": "batch"}
    expectation_type = "expect_column_values_to_be_in_set"
    expectation_config1 = ExpectationConfiguration(kwargs=kwargs1, expectation_type=expectation_type)
    validator_result1 = ExpectationValidationResult(result=result1, expectation_config=expectation_config1)
    result2 = {
        "element_count": 5,
        "unexpected_count": 1,
        "unexpected_percent": 20,
        "partial_unexpected_list": ["wrong"],
        "missing_count": 0,
        "missing_percent": 0.0,
        "unexpected_percent_total": 20,
        "unexpected_percent_nonmissing": 20,
        "partial_unexpected_index_list": None,
        "partial_unexpected_counts": [
            {"value": "wrong", "count": 1},
        ],
        "unexpected_list": [
            "wrong",
        ],
        "unexpected_index_list": None,
    }
    kwargs2 = {
        "column": "col1",
        "result_format": "COMPLETE",
        "batch_id": "batch",
        "mostly": 0.99,
        "value_set": ["right", "blah", "A", "C", "E"],
    }
    expectation_config2 = ExpectationConfiguration(kwargs=kwargs2, expectation_type=expectation_type)
    validator_result2 = ExpectationValidationResult(
        success=False, result=result2, expectation_config=expectation_config2
    )
    expectation_results = [validator_result1, validator_result2]
    return expectation_results


def test_publish_quality_results_table(mocker, spark, expectation_results):
    base_path = "a/fake/path/"
    datasource_name = "fake_database"
    data_quality_run_date = date(year=2000, month=1, day=1)

    expected_cols = [
        "data_quality_run_date",
        "datasource_name",
        "column_name",
        "validator",
        "value_set",
        "threshold",
        "failure_count",
        "failure_percent",
        "success",
    ]
    expected_data = [
        (
            data_quality_run_date,
            datasource_name,
            "col1",
            "expect_column_values_to_be_in_set",
            "[right, blah, A, C, E]",
            "0.99",
            "1",
            "20",
            False,
        )
    ]

    expected_failure = spark.createDataFrame(data=expected_data, schema=expected_cols)

    mocker.patch("pysparkle.data_quality.utils.save_dataframe_as_delta")
    failed_validations = publish_quality_results_table(
        spark, base_path, datasource_name, expectation_results, data_quality_run_date
    )
    assert sorted(failed_validations.collect()) == sorted(expected_failure.collect())
