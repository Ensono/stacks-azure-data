from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeDirectoryClient
from constants import ADLS_URL, SQL_DB_INGEST_DIRECTORY_NAME, RAW_CONTAINER_NAME
from behave import fixture


def delete_directory_adls(client: DataLakeDirectoryClient, directory_path: str):
    if client.exists():
        client.delete_directory()
    else:
        print(f"The Following Directory Was Not Found: {directory_path}")


@fixture
def azure_adls_clean_up(context):
    credential = DefaultAzureCredential()
    adls_client = DataLakeDirectoryClient(account_url=ADLS_URL, credential=credential, file_system_name=RAW_CONTAINER_NAME,
                                     directory_name=SQL_DB_INGEST_DIRECTORY_NAME)

    directory_path = f"{ADLS_URL}/{RAW_CONTAINER_NAME}/{SQL_DB_INGEST_DIRECTORY_NAME}"

    print(f"BEFORE SCENARIO. ATTEMPTING TO DELETE DIRECTORY: {directory_path}")

    delete_directory_adls(adls_client, directory_path)

    yield context

    print(f"AFTER SCENARIO. ATTEMPTING TO DELETE DIRECTORY: {directory_path}")

    delete_directory_adls(adls_client, directory_path)
