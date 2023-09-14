from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeServiceClient
from behave import fixture
from behave.runner import Context
from utils.constants import (
    ADLS_URL,
    RAW_CONTAINER_NAME,
    AUTOMATED_TEST_OUTPUT_DIRECTORY_PREFIX,
)
from utils.azure.adls import filter_directory_paths_adls, delete_directories_adls


@fixture
def azure_adls_clean_up(context: Context, ingest_directory_name: str):
    """Delete test directories in ADLS.

    Args:
        context: Behave context object.
        ingest_directory_name: Name of the ADLS directory to delete.
    """
    credential = DefaultAzureCredential()
    adls_client = DataLakeServiceClient(account_url=ADLS_URL, credential=credential)
    print("BEFORE SCENARIO. DELETING ANY AUTOMATED TEST OUTPUT DATA")
    automated_test_output_directory_paths = filter_directory_paths_adls(
        adls_client,
        RAW_CONTAINER_NAME,
        ingest_directory_name,
        AUTOMATED_TEST_OUTPUT_DIRECTORY_PREFIX,
    )

    delete_directories_adls(adls_client, RAW_CONTAINER_NAME, automated_test_output_directory_paths)

    yield context

    print("AFTER SCENARIO. DELETING ANY AUTOMATED TEST OUTPUT DATA")

    automated_test_output_directory_paths = filter_directory_paths_adls(
        adls_client,
        RAW_CONTAINER_NAME,
        ingest_directory_name,
        AUTOMATED_TEST_OUTPUT_DIRECTORY_PREFIX,
    )

    delete_directories_adls(adls_client, RAW_CONTAINER_NAME, automated_test_output_directory_paths)
