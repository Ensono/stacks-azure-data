import pytest
from jsonschema import validate

from stacks.data.utils import (
    config_uniqueness_check,
    load_config_as_dict,
    load_configs_as_list,
)

CONFIG_PATH = "de_workloads/ingest/ingest_azure_sql_example/config"
INGEST_CONFIG_PATH = f"{CONFIG_PATH}/ingest_sources"
INGEST_DQ_CONFIG_PATH = f"{CONFIG_PATH}/data_quality"
INGEST_CONFIG_SCHEMA = f"{CONFIG_PATH}/schema/ingest_config_schema.json"
INGEST_DQ_CONFIG_SCHEMA = f"{CONFIG_PATH}/schema/data_quality_config_schema.json"


@pytest.mark.parametrize(
    "config_path, config_schema",
    [
        (INGEST_CONFIG_PATH, INGEST_CONFIG_SCHEMA),
        (INGEST_DQ_CONFIG_PATH, INGEST_DQ_CONFIG_SCHEMA),
    ],
)
def test_config_ingest_schemas_valid(config_path, config_schema):
    schema = load_config_as_dict(config_schema)
    all_configs = load_configs_as_list(config_path)
    assert all_configs
    errors = []
    for config in all_configs:
        try:
            validate(config, schema)
        except Exception as e:
            errors.append(e)
    if errors:
        raise Exception(errors)


def test_config_ingest_sources_uniqueness():
    all_configs = load_configs_as_list(INGEST_CONFIG_PATH)
    errors = []
    try:
        assert config_uniqueness_check(all_configs, "data_source_name")
    except Exception as e:
        errors.append(e)
    for config in all_configs:
        try:
            ingest_entities = config["ingest_entities"]
            assert config_uniqueness_check(ingest_entities, "display_name")
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
