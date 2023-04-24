from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeDirectoryClient
from constants import ADLS_URL, SQL_DB_INGEST_DIRECTORY_NAME, RAW_CONTAINER_NAME
from azure.core.exceptions import ResourceNotFoundError
from behave import fixture


@fixture
def azure_adls_clean_up(context):
    credential = DefaultAzureCredential()
    client = DataLakeDirectoryClient(account_url=ADLS_URL, credential=credential, file_system_name=RAW_CONTAINER_NAME,
                                     directory_name=SQL_DB_INGEST_DIRECTORY_NAME)

    directory_path = f"{ADLS_URL}/{RAW_CONTAINER_NAME}/{SQL_DB_INGEST_DIRECTORY_NAME}"
    print(f"BEFORE SCENARIO. DELETING DIRECTORY: {directory_path}")

    try:
        client.delete_directory()
    except ResourceNotFoundError:
        print(f"The Following Directory Was Not Found: {directory_path}")
    except Exception:
        raise

    yield context

    print(f"AFTER SCENARIO. DELETING DIRECTORY: {directory_path}")
    try:
        client.delete_directory()
    except ResourceNotFoundError:
        print(f"The Following Directory Was Not Found: {directory_path}")
    except Exception:
        raise