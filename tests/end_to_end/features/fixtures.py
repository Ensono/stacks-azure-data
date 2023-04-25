from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeDirectoryClient, DataLakeServiceClient, FileSystemClient
from constants import ADLS_URL, SQL_DB_INGEST_DIRECTORY_NAME, RAW_CONTAINER_NAME
from behave import fixture


def get_automated_test_output_dir_paths(client: FileSystemClient, path: str):
    automated_test_output_dir_paths = []
    for path in client.get_paths(path=path):
        if path.is_directory and 'automated_test' in path.name:
            automated_test_output_dir_paths.append(path.name)
    return automated_test_output_dir_paths


def delete_directories_adls(adls_client, directory_paths: list):
    for directory_path in directory_paths:
        adls_directory_client = adls_client.get_directory_client(directory_path)
        print(f"ATTEMPTING TO DELETE DIRECTORY: {directory_path}")
        delete_directory_adls(adls_directory_client, directory_path)


def delete_directory_adls(client: DataLakeDirectoryClient, directory_path: str):
    if client.exists():
        client.delete_directory()
    else:
        print(f"The Following Directory Was Not Found: {directory_path}")


@fixture
def azure_adls_clean_up(context):
    credential = DefaultAzureCredential()
    adls_client = DataLakeServiceClient(account_url=ADLS_URL, credential=credential)
    adls_fs_client = adls_client.get_file_system_client(RAW_CONTAINER_NAME, path=path)

    print('BEFORE SCENARIO. DELETING ANY AUTOMATED TEST OUTPUT DATA')

    automated_test_output_dir_paths = get_automated_test_output_dir_paths(adls_fs_client)
    delete_directories_adls(automated_test_output_dir_paths)

    yield context

    print('AFTER SCENARIO. DELETING ANY AUTOMATED TEST OUTPUT DATA')

    automated_test_output_dir_paths = get_automated_test_output_dir_paths(adls_fs_client)
    delete_directories_adls(automated_test_output_dir_paths)
