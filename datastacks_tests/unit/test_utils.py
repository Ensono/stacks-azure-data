import json
from pathlib import Path
from shutil import rmtree
from unittest.mock import patch

from datastacks.config import INGEST_TEMPLATE_FOLDER
from datastacks.config_class import IngestConfig
from datastacks.utils import (
    generate_pipeline,
    generate_target_dir,
    render_template_components,
)
from datastacks_tests.unit.template_structures import (
    EXPECTED_FILE_LIST,
    EXPECTED_DQ_FILE_LIST,
)


def test_render_template_components(tmp_path):
    config_dict = {
        "dataset_name": "test_dataset",
        "pipeline_description": "Pipeline for testing",
        "data_source_type": "azure_sql",
        "key_vault_linked_service_name": "test_keyvault",
        "data_source_password_key_vault_secret_name": "test_password",
        "data_source_connection_string_variable_name": "test_connection_string",
        "ado_variable_groups_nonprod": ["nonprod_test_group"],
        "ado_variable_groups_prod": ["prod_group"],
        "bronze_container": "test_raw",
    }
    config = IngestConfig.parse_obj(config_dict)

    template_source_path = f"de_templates/ingest/Ingest_SourceType_SourceName/"
    target_dir = f"{tmp_path}/test_render"

    render_template_components(config, template_source_path, target_dir)

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()


@patch("datastacks.utils.click.confirm")
@patch("datastacks.utils.generate_target_dir")
def test_generate_pipeline_no_dq(mock_target_dir, mock_confirm, tmp_path):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = "Y"
    config_path = "datastacks_tests/unit/test_config.yml"
    template_source_folder = INGEST_TEMPLATE_FOLDER

    target_dir = generate_pipeline(config_path, False, template_source_folder, "Ingest")

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()


@patch("datastacks.utils.click.confirm")
@patch("datastacks.utils.generate_target_dir")
def test_generate_pipeline_no_overwrite(mock_target_dir, mock_confirm, tmp_path):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = False

    config_path = "datastacks_tests/unit/test_config.yml"
    template_source_folder = INGEST_TEMPLATE_FOLDER

    target_dir = generate_pipeline(config_path, False, template_source_folder, "Ingest")

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()

    
@patch("datastacks.utils.click.confirm")
@patch("datastacks.utils.generate_target_dir")
def test_generate_pipeline_dq(mock_target_dir, mock_confirm, tmp_path):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = "Y"
    config_path = "datastacks_tests/unit/test_config.yml"
    template_source_folder = INGEST_TEMPLATE_FOLDER

    patch("datastacks.utils.generate_target_dir", return_value=tmp_path)
    target_dir = generate_pipeline(config_path, True, template_source_folder, "Ingest")

    full_file_list = EXPECTED_FILE_LIST+EXPECTED_DQ_FILE_LIST

    for file_path in full_file_list:
        assert Path(f"{target_dir}/{file_path}").exists()


@patch("datastacks.utils.click.confirm")
def test_generate_pipeline_new_path(mock_confirm):
    mock_confirm.return_value = False

    config_path = "datastacks_tests/unit/test_config.yml"
    template_source_folder = INGEST_TEMPLATE_FOLDER

    target_dir = generate_pipeline(config_path, False, template_source_folder, "Ingest")

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()

    rmtree(target_dir)


@patch("datastacks.utils.click.confirm")
@patch("datastacks.utils.generate_target_dir")
def test_generate_pipeline_no_overwrite(mock_target_dir, mock_confirm, tmp_path):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = True

    config_path = "datastacks_tests/unit/test_config.yml"
    template_source_folder = INGEST_TEMPLATE_FOLDER

    target_dir = generate_pipeline(config_path, False, template_source_folder, "Ingest")

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()

    with open(f"{target_dir}/data_factory/pipelines/ARM_IngestTemplate.json") as file:
        arm_template_dict = json.load(file)
    assert arm_template_dict["resources"][0]["properties"]["description"] == "Pipeline for testing"
    
    config_path = "datastacks_tests/unit/test_config_overwrite.yml"
    mock_confirm.return_value = False
    target_dir = generate_pipeline(config_path, False, template_source_folder, "Ingest")
        
    with open(f"{target_dir}/data_factory/pipelines/ARM_IngestTemplate.json") as file:
        arm_template_dict = json.load(file)
    assert arm_template_dict["resources"][0]["properties"]["description"] == "Pipeline for testing"


@patch("datastacks.utils.click.confirm")
@patch("datastacks.utils.generate_target_dir")
def test_generate_pipeline_overwrites(mock_target_dir, mock_confirm, tmp_path):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = True

    config_path = "datastacks_tests/unit/test_config.yml"
    template_source_folder = INGEST_TEMPLATE_FOLDER

    target_dir = generate_pipeline(config_path, False, template_source_folder, "Ingest")

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()

    with open(f"{target_dir}/data_factory/pipelines/ARM_IngestTemplate.json") as file:
        arm_template_dict = json.load(file)
    assert arm_template_dict["resources"][0]["properties"]["description"] == "Pipeline for testing"

    config_path = "datastacks_tests/unit/test_config_overwrite.yml"
    target_dir = generate_pipeline(config_path, False, template_source_folder, "ingest")

    with open(f"{target_dir}/data_factory/pipelines/ARM_IngestTemplate.json") as file:
        arm_template_dict = json.load(file)
    assert arm_template_dict["resources"][0]["properties"]["description"] == "Pipeline for testing overwritten"


@patch("datastacks.utils.click.confirm")
@patch("datastacks.utils.generate_target_dir")
def test_enum_templating(mock_target_dir, mock_confirm, tmp_path):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = True

    config_path = "datastacks_tests/unit/test_config.yml"
    template_source_folder = INGEST_TEMPLATE_FOLDER

    target_dir = generate_pipeline(config_path, False, template_source_folder, "Ingest")

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()

    with open(f"{target_dir}/data_factory/pipelines/ARM_IngestTemplate.json") as file:
        arm_template_dict = json.load(file)
    assert arm_template_dict["resources"][0]["properties"]["activities"][1]["typeProperties"]["activities"][0]["name"] == "AZURE_SQL_to_ADLS"


def test_generate_target_dir():
    assert generate_target_dir("a", "b") == "de_workloads/a/a_b"
