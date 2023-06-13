import shutil
from pathlib import Path

from pysparkle.dq.data_quality_utils import *

TEST_GX_DIR = Path(__file__).parent.resolve() / "great_expectations"

TEST_DQ_CONF = {
    "container_name": "staging",
    "datasource_name": "movies_metadata",
    "expectation_suite_name": "movies_metadata_suite",
    "gx_directory_path": TEST_GX_DIR,
    "validation_config": [
        {
            "column_name": "adult",
            "expectations": [
                {
                    "expectation_type": "expect_column_values_to_not_be_null",
                    "expectation_kwargs": {},
                }
            ],
        }
    ],
}


def test_create_datasource_context():
    context = create_datasource_context(
        TEST_DQ_CONF["datasource_name"], TEST_DQ_CONF["gx_directory_path"]
    )
    assert context.list_datasources()[0]["name"] == TEST_DQ_CONF["datasource_name"]
    assert (
        list(context.list_datasources()[0]["data_connectors"].keys())[0]
        == f'{TEST_DQ_CONF["datasource_name"]}_data_connector'
    )
    shutil.rmtree(TEST_DQ_CONF["gx_directory_path"])


def test_add_expectations_for_columns():
    context = create_datasource_context(
        TEST_DQ_CONF["datasource_name"], TEST_DQ_CONF["gx_directory_path"]
    )
    expectation_suite = context.create_expectation_suite(
        expectation_suite_name=TEST_DQ_CONF["expectation_suite_name"],
        overwrite_existing=True,
    )
    expectation_suite = add_expectations_for_columns(
        expectation_suite, TEST_DQ_CONF["validation_config"]
    )

    expectation = expectation_suite.to_json_dict()["expectations"]
    assert expectation[0]["kwargs"] == {"column": "adult"}
    assert expectation[0]["expectation_type"] == "expect_column_values_to_not_be_null"

    shutil.rmtree(TEST_DQ_CONF["gx_directory_path"])


def test_create_expectation_suite():
    context = create_datasource_context(
        TEST_DQ_CONF["datasource_name"], TEST_DQ_CONF["gx_directory_path"]
    )
    assert context.list_expectation_suite_names() == []

    context = create_expectation_suite(
        context,
        TEST_DQ_CONF,
    )

    assert context.list_expectation_suite_names() == ["movies_metadata_suite"]

    expectation_suite = context.get_expectation_suite("movies_metadata_suite")
    expectation = expectation_suite.to_json_dict()["expectations"]

    assert expectation[0]["kwargs"] == {"column": "adult"}
    assert expectation[0]["expectation_type"] == "expect_column_values_to_not_be_null"

    shutil.rmtree(TEST_DQ_CONF["gx_directory_path"])
