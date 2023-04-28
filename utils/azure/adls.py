from azure.storage.filedatalake import DataLakeServiceClient


def filter_directory_paths_adls(adls_client: DataLakeServiceClient, container_name: str, directory_path: str,
                                directory_substring: str) -> list:
    """
    Filters an ADLS container directory for directories containing a given substring.

    :param adls_client:               DataLakeServiceClient
    :param container_name:            Container / file system
    :param directory_path:            Directory
    :param directory_substring:      String to be found in directory
    :return:
        list of directory paths containing the sub_directory prefix
    """
    adls_fs_client = adls_client.get_file_system_client(container_name)
    output_directory_paths = []
    if adls_fs_client.get_directory_client(directory_path).exists():
        paths = adls_fs_client.get_paths(directory_path)
        for path in paths:
            if path.is_directory and directory_substring in path.name:
                output_directory_paths.append(path.name)
    return output_directory_paths


def delete_directories_adls(adls_client: DataLakeServiceClient, container_name: str, directory_paths: list):
    """
    Deletes a list of directories from ADLS.

    :param adls_client:     DataLakeServiceClient
    :param container_name:  Container / file system
    :param directory_paths: list of directories to delete
    :return:
        None
    """
    for directory_path in directory_paths:
        print(f"ATTEMPTING TO DELETE DIRECTORY: {directory_path}")
        delete_directory_adls(adls_client, container_name, directory_path)


def delete_directory_adls(adls_client: DataLakeServiceClient, container_name, directory_path: str):
    """
    Deletes an ADLS directory.

    :param adls_client:     DataLakeServiceClient
    :param container_name:  Container / File System
    :param directory_path:  A directory path
    :return:
        None
    """
    adls_directory_client = adls_client.get_directory_client(container_name, directory_path)
    if adls_directory_client.exists():
        adls_directory_client.delete_directory()
    else:
        print(f"The Following Directory Was Not Found: {directory_path}")


def all_files_present_in_adls(adls_client: DataLakeServiceClient, container_name: str, directory_name: str,
                              expected_files: list) -> bool:
    """
    Asserts all files in a given list are present in the specified container and directory.

    :param adls_client:     DataLakeServiceClient
    :param container_name:  Container / File System
    :param directory_name:  Directory Name
    :param expected_files:  List of Expected Files
    :return:
        bool
    """
    adls_fs_client = adls_client.get_file_system_client(container_name)
    actual_paths = adls_fs_client.get_paths(directory_name)
    for expected_file in expected_files:
        assert any(expected_file in actual_output_file.name for actual_output_file in actual_paths)
    return True
