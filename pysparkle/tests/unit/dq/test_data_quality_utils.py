from pysparkle.dq.data_quality_utils import *


def test_create_datasource_context(dq_config, datasource_context):
    assert datasource_context.list_datasources()[0]["name"] == dq_config["datasource_name"]
    assert (
        list(datasource_context.list_datasources()[0]["data_connectors"].keys())[0]
        == f'{dq_config["datasource_name"]}_data_connector'
    )


def test_add_expectations_for_columns(dq_config):
    expectation_suite = ExpectationSuite(expectation_suite_name="test_suite")
    validation_config = dq_config["validation_config"]

    expectation_suite = add_expectations_for_columns(expectation_suite, validation_config)
    expectations = expectation_suite.expectations

    assert len(expectations) == 3
    assert expectations[0].expectation_type == "expect_column_values_to_not_be_null"
    assert expectations[0].kwargs["column"] == "test_column_1"
    assert expectations[1].expectation_type == "expect_column_values_to_be_of_type"
    assert expectations[1].kwargs["column"] == "test_column_1"
    assert expectations[1].kwargs["type_"] == "string"
    assert expectations[2].expectation_type == "expect_column_values_to_be_in_set"
    assert expectations[2].kwargs["column"] == "test_column_2"
    assert expectations[2].kwargs["value_set"] == [1, 2, 3]


def test_add_expectation_suite(dq_config, datasource_context):

    assert datasource_context.list_expectation_suite_names() == []

    context = add_expectation_suite(datasource_context, dq_config)
    expected_suite_name = dq_config["expectation_suite_name"]

    assert context.list_expectation_suite_names() == [expected_suite_name]

    expectation_suite = context.get_expectation_suite(expected_suite_name)
    expectations = expectation_suite.expectations

    test_suite = ExpectationSuite(expectation_suite_name="test_suite")
    test_config = dq_config["validation_config"]
    test_suite = add_expectations_for_columns(test_suite, test_config)
    test_expectations = test_suite.expectations
    assert test_expectations == expectations


def test_execute_validations():
    # TODO
    pass
