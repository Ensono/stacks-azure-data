import json
from pathlib import Path
from shutil import rmtree
from unittest.mock import patch

import pytest

from datastacks.cli.config import IngestWorkloadConfigModel
from datastacks.cli.utils import (
    validate_yaml_config,
    generate_pipeline,
    generate_target_dir,
    render_template_components,
)
from tests.unit.cli.template_structures import EXPECTED_DQ_FILE_LIST, EXPECTED_FILE_LIST


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
    config = IngestWorkloadConfigModel(**config_dict)

    template_source_path = "de_templates/ingest/Ingest_SourceType_SourceName/"
    target_dir = f"{tmp_path}/test_render"

    render_template_components(config, template_source_path, target_dir)

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()


@pytest.mark.parametrize(
    "dq,expected_files", [(False, EXPECTED_FILE_LIST), (True, EXPECTED_FILE_LIST + EXPECTED_DQ_FILE_LIST)]
)
@patch("datastacks.cli.utils.click.confirm")
@patch("datastacks.cli.utils.generate_target_dir")
def test_generate_pipeline(mock_target_dir, mock_confirm, tmp_path, dq, expected_files):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = True
    config_path = "datastacks/tests/unit/cli/test_config.yml"

    validated_config = validate_yaml_config(config_path, IngestWorkloadConfigModel)
    target_dir = generate_pipeline(validated_config, dq)

    for file_path in expected_files:
        assert Path(f"{target_dir}/{file_path}").exists()


@patch("datastacks.cli.utils.click.confirm")
@patch("datastacks.cli.utils.generate_target_dir")
def test_generate_pipeline_new_path(mock_target_dir, mock_confirm, tmp_path):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = False
    rmtree(tmp_path)

    config_path = "datastacks/tests/unit/cli/test_config.yml"

    validated_config = validate_yaml_config(config_path, IngestWorkloadConfigModel)
    target_dir = generate_pipeline(validated_config, False)

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()


@pytest.mark.parametrize(
    "overwrite_confirm,expected_desc", [(False, "Pipeline for testing"), (True, "Pipeline for testing overwritten")]
)
@patch("datastacks.cli.utils.click.confirm")
@patch("datastacks.cli.utils.generate_target_dir")
def test_generate_pipeline_overwrite(mock_target_dir, mock_confirm, tmp_path, overwrite_confirm, expected_desc):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = True

    config_path = "datastacks/tests/unit/cli/test_config.yml"

    validated_config = validate_yaml_config(config_path, IngestWorkloadConfigModel)
    target_dir = generate_pipeline(validated_config, False)

    for file_path in EXPECTED_FILE_LIST:
        assert Path(f"{target_dir}/{file_path}").exists()

    with open(f"{target_dir}/data_factory/pipelines/ARM_IngestTemplate.json") as file:
        arm_template_dict = json.load(file)
    assert arm_template_dict["resources"][0]["properties"]["description"] == "Pipeline for testing"

    config_path = "datastacks/tests/unit/cli/test_config_overwrite.yml"
    mock_confirm.return_value = overwrite_confirm

    validated_config = validate_yaml_config(config_path, IngestWorkloadConfigModel)
    target_dir = generate_pipeline(validated_config, False)

    with open(f"{target_dir}/data_factory/pipelines/ARM_IngestTemplate.json") as file:
        arm_template_dict = json.load(file)
    assert arm_template_dict["resources"][0]["properties"]["description"] == expected_desc


@patch("datastacks.cli.utils.click.confirm")
@patch("datastacks.cli.utils.generate_target_dir")
def test_enum_templating(mock_target_dir, mock_confirm, tmp_path):
    mock_target_dir.return_value = tmp_path
    mock_confirm.return_value = True

    config_path = "datastacks/tests/unit/cli/test_config.yml"

    validated_config = validate_yaml_config(config_path, IngestWorkloadConfigModel)
    target_dir = generate_pipeline(validated_config, False)

    tested_file_path = f"{target_dir}/data_factory/pipelines/ARM_IngestTemplate.json"

    assert Path(f"{tested_file_path}").exists()

    with open(tested_file_path) as file:
        arm_template_dict = json.load(file)
    assert (
        arm_template_dict["resources"][0]["properties"]["activities"][1]["typeProperties"]["activities"][0]["name"]
        == "AZURE_SQL_to_ADLS"
    )


def test_generate_target_dir():
    assert generate_target_dir("a", "b") == "de_workloads/a/b"
