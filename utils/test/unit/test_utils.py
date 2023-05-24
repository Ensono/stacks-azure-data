import logging

from collections import Counter
from jsonschema import validate

from utils.config_utils import load_config_as_dict, load_configs_as_list
from utils.constants import INGEST_SOURCES_DIR, INGEST_SOURCES_SCHEMA_PATH
from utils.testing_utils import config_uniqueness_check


def test_config_ingest_sources_schema_valid():
    schema = load_config_as_dict(INGEST_SOURCES_SCHEMA_PATH, "utils/test")
    all_configs = load_configs_as_list(INGEST_SOURCES_DIR, "utils/test")
    for config in all_configs:
        validate(config, schema)


def test_config_ingest_sources_uniqueness():
    all_configs = load_configs_as_list(INGEST_SOURCES_DIR, "utils/test")
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
