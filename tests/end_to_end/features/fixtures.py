from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeServiceClient
from constants import ADLS_URL, RAW_CONTAINER_NAME, AUTOMATED_TEST_OUTPUT_DIRECTORY_PREFIX
from behave import fixture


def filter_fs_paths_adls(adls_client: DataLakeServiceClient, directory_name: str,
                         sub_directory_prefix: str) -> list:
    adls_fs_client = adls_client.get_file_system_client(RAW_CONTAINER_NAME)
    output_directory_paths = []
    if adls_fs_client.get_directory_client(directory_name).exists():
        paths = adls_fs_client.get_paths(directory_name)
        for path in paths:
            if path.is_directory and sub_directory_prefix in path.name:
                output_directory_paths.append(path.name)
    return output_directory_paths


def delete_directories_adls(adls_client: DataLakeServiceClient, container_name: str, directory_paths: list):
    for directory_path in directory_paths:
        print(f"ATTEMPTING TO DELETE DIRECTORY: {directory_path}")
        delete_directory_adls(adls_client, container_name, directory_path)


def delete_directory_adls(adls_client: DataLakeServiceClient, container_name, directory_path: str):
    adls_directory_client = adls_client.get_directory_client(container_name, directory_path)
    if adls_directory_client.exists():
        adls_directory_client.delete_directory()
    else:
        print(f"The Following Directory Was Not Found: {directory_path}")


@fixture
def azure_adls_clean_up(context, ingest_directory_name: str):
    credential = DefaultAzureCredential()
    adls_client = DataLakeServiceClient(account_url=ADLS_URL, credential=credential)

    print('BEFORE SCENARIO. DELETING ANY AUTOMATED TEST OUTPUT DATA')

    automated_test_output_directory_paths = filter_fs_paths_adls(adls_client,
                                                                 ingest_directory_name,
                                                                 AUTOMATED_TEST_OUTPUT_DIRECTORY_PREFIX)

    if automated_test_output_directory_paths:
        delete_directories_adls(adls_client, RAW_CONTAINER_NAME, automated_test_output_directory_paths)

    yield context

    print('AFTER SCENARIO. DELETING ANY AUTOMATED TEST OUTPUT DATA')

    automated_test_output_directory_paths = filter_fs_paths_adls(adls_client,
                                                                 ingest_directory_name,
                                                                 AUTOMATED_TEST_OUTPUT_DIRECTORY_PREFIX)

    if automated_test_output_directory_paths:
        delete_directories_adls(adls_client, RAW_CONTAINER_NAME, automated_test_output_directory_paths)
