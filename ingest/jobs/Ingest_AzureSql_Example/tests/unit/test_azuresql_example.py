import logging

from collections import Counter
from jsonschema import validate

from utils.config_utils import load_config_as_dict, load_configs_as_list
from utils.constants import INGEST_SOURCES_DIR, INGEST_SOURCES_SCHEMA_PATH


def test_config_ingest_sources_schema_valid():
    schema = load_config_as_dict(INGEST_SOURCES_SCHEMA_PATH, "ingest")
    all_configs = load_configs_as_list(INGEST_SOURCES_DIR, "ingest")
    for config in all_configs:
        validate(config, schema)


def test_config_ingest_sources_uniqueness():
    all_configs = load_configs_as_list(INGEST_SOURCES_DIR, "ingest")
    assert config_uniqueness_check(all_configs, "data_source_name")
    for config in all_configs:
        ingest_entities = config["ingest_entities"]
        assert config_uniqueness_check(ingest_entities, "display_name")


def config_uniqueness_check(config_list: list[dict], unique_key: str):
    key_counter = Counter(i[unique_key] for i in config_list)
    for config in config_list:
        if key_counter[config[unique_key]] == 1:
            continue
        else:
            logging.error(f"{unique_key} value is not unique: {config[unique_key]}")
            return False
    return True
