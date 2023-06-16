from pytest import fixture

from pysparkle.dq.data_quality_utils import create_datasource_context


@fixture
def dq_config(tmp_path):
    gx_directory_path = str(tmp_path)

    return {
        "container_name": "staging",
        "datasource_name": "movies_metadata",
        "expectation_suite_name": "movies_metadata_suite",
        "gx_directory_path": gx_directory_path,
        "validation_config": [
            {
                "column_name": "test_column_1",
                "expectations": [
                    {
                        "expectation_type": "expect_column_values_to_not_be_null",
                        "expectation_kwargs": {},
                    },
                    {
                        "expectation_type": "expect_column_values_to_be_of_type",
                        "expectation_kwargs": {"type_": "string"},
                    },
                ],
            },
            {
                "column_name": "test_column_2",
                "expectations": [
                    {
                        "expectation_type": "expect_column_values_to_be_in_set",
                        "expectation_kwargs": {"value_set": [1, 2, 3]},
                    }
                ],
            }
        ]
    }


@fixture
def datasource_context(dq_config):
    datasource_name = dq_config["datasource_name"]
    gx_directory_path = dq_config["gx_directory_path"]
    context = create_datasource_context(datasource_name, gx_directory_path)
    return context
