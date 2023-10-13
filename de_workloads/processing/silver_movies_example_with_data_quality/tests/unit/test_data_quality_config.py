from jsonschema import validate

from datastacks.utils import (
    config_uniqueness_check,
    load_config_as_dict,
    load_configs_as_list,
)

CONFIG_PATH = "de_workloads/processing/silver_movies_example_with_data_quality/config"
INGEST_DQ_CONFIG_PATH = f"{CONFIG_PATH}/data_quality"
INGEST_DQ_CONFIG_SCHEMA = f"{CONFIG_PATH}/schema/data_quality_config_schema.json"


def test_config_processing_schemas_valid():
    schema = load_config_as_dict(INGEST_DQ_CONFIG_SCHEMA)
    all_configs = load_configs_as_list(INGEST_DQ_CONFIG_PATH)
    assert all_configs
    errors = []
    for config in all_configs:
        try:
            validate(config, schema)
        except Exception as e:
            errors.append(e)
    if errors:
        raise Exception(errors)


def test_config_ingest_dq_uniqueness():
    all_configs = load_configs_as_list(INGEST_DQ_CONFIG_PATH)
    errors = []
    for config in all_configs:
        try:
            dq_expectation_suites = config["datasource_config"]
            assert config_uniqueness_check(dq_expectation_suites, "expectation_suite_name")
        except Exception as e:
            errors.append(e)
    if errors:
        raise Exception(errors)
