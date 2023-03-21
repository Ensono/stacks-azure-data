from collections import Counter
from jsonschema import validate

from utils.config_utils import load_config_as_dict, load_configs_as_list
from utils.constants import INGEST_SOURCES_DIR, INGEST_SOURCES_SCHEMA_PATH


def test_config_ingest_sources_schema_valid():
    schema = load_config_as_dict(INGEST_SOURCES_SCHEMA_PATH)
    all_configs = load_configs_as_list(INGEST_SOURCES_DIR)
    for config in all_configs:
        validate(config, schema)


def test_config_ingest_sources_uniqueness():
    all_configs = load_configs_as_list(INGEST_SOURCES_DIR)

    # Data sources unique
    data_source_counts = Counter(i["data_source_name"] for i in all_configs)
    for config in all_configs:
        assert data_source_counts[config["data_source_name"]] == 1

        # Ingest entities unique per source
        entity_counts = Counter(i["display_name"] for i in config["ingest_entities"])
        for entity in config["ingest_entities"]:
            assert entity_counts[entity["display_name"]] == 1
