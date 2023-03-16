from jsonschema import validate

from utils.config_utils import load_config_as_dict, load_configs_as_list


def test_config_valid_ingest_sources():
    ingest_sources_dir = "ingest-sources"
    schema = load_config_as_dict(
        f"{ingest_sources_dir}/schema/ingest_config_schema.json"
    )
    for config in load_configs_as_list(ingest_sources_dir):
        validate(config, schema)
