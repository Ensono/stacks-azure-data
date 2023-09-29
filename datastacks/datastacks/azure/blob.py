import logging
from azure.storage.blob import BlobServiceClient

logger = logging.getLogger(__name__)


def upload_file_to_blob(
    blob_service_client: BlobServiceClient,
    container_name: str,
    target_dir: str,
    config_file_path: str,
    overwrite: bool = True,
) -> bool:
    """Upload a file to blob storage.

    Args:
        blob_service_client: BlobServiceClient
        container_name: Container name
        target_dir: Directory to load into
        config_file_path: Filepath of the file to upload
        overwrite: Overwrite the file if it already exists

    Returns:
        Boolean reflecting whether upload was successful
    """
    target_blob_path = f"{target_dir}/{config_file_path}"

    container_client = blob_service_client.get_container_client(container_name)
    blob_client = container_client.get_blob_client(target_blob_path)

    with open(config_file_path, "rb") as file:
        blob_client.upload_blob(file, overwrite=overwrite)
    logger.info(f"Uploaded {config_file_path} to {container_name}/{target_blob_path}.")
    return True
