import os
from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeDirectoryClient
from constants import ADLS_URL, SQL_DB_INGEST_DIRECTORY_NAME, RAW_CONTAINER_NAME
from azure.core.exceptions import ResourceNotFoundError


def before_scenario(context, scenario):
    credential = DefaultAzureCredential()
    client = DataLakeDirectoryClient(account_url=ADLS_URL, credential=credential, file_system_name=RAW_CONTAINER_NAME,
                                     directory_name=SQL_DB_INGEST_DIRECTORY_NAME)
    print(f"BEFORE SCENARIO. DELETING DIRECTORY: {ADLS_URL}/{RAW_CONTAINER_NAME}/{SQL_DB_INGEST_DIRECTORY_NAME}")

    try:
        client.delete_directory()
    except ResourceNotFoundError:
        print(f"The Following Directory Was Not Found: {ADLS_URL}/{RAW_CONTAINER_NAME}/{SQL_DB_INGEST_DIRECTORY_NAME}")
    except Exception as e:
        raise
