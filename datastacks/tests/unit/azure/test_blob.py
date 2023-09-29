import pytest
from unittest.mock import Mock, patch, mock_open
from azure.storage.blob import BlobServiceClient
from datastacks.azure.blob import upload_file_to_blob


@pytest.fixture
def azure_blob_service_client():
    return Mock(spec=BlobServiceClient)


def test_upload_file_to_blob(azure_blob_service_client):
    container_name = "test_container"
    target_dir = "test_directory"
    config_file_path = "datastacks/tests/data/ingest_sources/test_config.json"
    overwrite = False

    mock_blob_service_client = azure_blob_service_client.return_value
    mock_container_client = mock_blob_service_client.get_container_client.return_value
    mock_blob_client = mock_container_client.get_blob_client.return_value

    with patch("builtins.open", mock_open()) as mock_file:
        result = upload_file_to_blob(mock_blob_service_client, container_name, target_dir, config_file_path, overwrite)
        mock_container_client.get_blob_client.assert_called_once_with(f"{target_dir}/{config_file_path}")
        mock_blob_client.upload_blob.assert_called_once_with(mock_file(), overwrite=overwrite)
        assert result is True
