from jsonschema import validate

from utils.config_utils import (
    config_uniqueness_check,
    load_config_as_dict,
    load_configs_as_list,
)

CONFIG_PATH = "de_workloads/ingest/Ingest_AzureSql_Example/config"
INGEST_CONFIG_PATH = f"{CONFIG_PATH}/ingest_sources"
INGEST_CONFIG_SCHEMA = f"{CONFIG_PATH}/schema/ingest_config_schema.json"


def test_config_ingest_sources_schema_valid():
    schema = load_config_as_dict(INGEST_CONFIG_SCHEMA)
    all_configs = load_configs_as_list(INGEST_CONFIG_PATH)
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
