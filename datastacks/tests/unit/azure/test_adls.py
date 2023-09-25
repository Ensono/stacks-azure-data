import pytest
from unittest.mock import Mock, MagicMock, patch, call
from datastacks.azure.adls import (
    delete_directories_adls,
    delete_directory_adls,
    # all_files_present_in_adls,
    # filter_directory_paths_adls,
)


@pytest.fixture
def adls_client_mock():
    return Mock()


def test_delete_directory_adls(adls_client_mock):
    container_name = "test_container"
    directory_path = "test_directory"

    adls_directory_client_mock = adls_client_mock.get_directory_client.return_value
    adls_directory_client_mock.exists.return_value = True

    delete_directory_adls(adls_client_mock, container_name, directory_path)

    adls_client_mock.get_directory_client.assert_called_once_with(container_name, directory_path)
    adls_directory_client_mock.exists.assert_called_once()
    adls_directory_client_mock.delete_directory.assert_called_once()


@patch("datastacks.azure.adls.delete_directory_adls")
def test_delete_directories_adls(delete_directory_adls_mock, adls_client_mock):
    container_name = "test_container"
    directory_paths = ["test_directory1", "test_directory2"]

    delete_directories_adls(adls_client_mock, container_name, directory_paths)

    delete_directory_adls_mock.assert_has_calls(
        [
            call(adls_client_mock, container_name, "test_directory1"),
            call(adls_client_mock, container_name, "test_directory2"),
        ]
    )


# def test_all_files_present_in_adls(adls_client_mock):
#     container_name = "test_container"
#     directory_name = "test_directory"
#     expected_files = ["file1.txt", "file2.txt", "file3.txt"]

#     # Mock the get_file_system_client and get_paths methods
#     adls_fs_client_mock = adls_client_mock.get_file_system_client.return_value
#     adls_fs_client_mock.get_paths.return_value = [
#         MagicMock(name="test_directory/file1.txt"),
#         MagicMock(name="test_directory/file2.txt"),
#         MagicMock(name="test_directory/file3.txt"),
#     ]

#     result = all_files_present_in_adls(adls_client_mock, container_name, directory_name, expected_files)

#     # Ensure the function returns True (all files present)
#     assert result is True

#     # Check if get_file_system_client and get_paths are called with the correct arguments
#     adls_client_mock.get_file_system_client.assert_called_once_with(container_name)
#     adls_fs_client_mock.get_paths.assert_called_once_with(directory_name)

#     # Check if the function asserts each expected file is in the actual paths
#     adls_fs_client_mock.get_paths.assert_called_once_with(directory_name)
#     for expected_file in expected_files:
#         assert any(
#             expected_file in actual_output_file.name
#             for actual_output_file in adls_fs_client_mock.get_paths.return_value
#         )


# def test_filter_directory_paths_adls(adls_client_mock):
#     container_name = "test_container"
#     directory_path = "test_directory"
#     directory_substring = "sub"

#     # Mock the get_file_system_client, get_directory_client, and get_paths methods
#     adls_fs_client_mock = adls_client_mock.get_file_system_client.return_value
#     adls_directory_client_mock = adls_fs_client_mock.get_directory_client.return_value
#     adls_directory_client_mock.exists.return_value = True

#     # Mock the get_paths method to return a list of MagicMock objects
#     adls_fs_client_mock.get_paths.return_value = [
#         MagicMock(is_directory=True, name="test_directory/sub_directory1"),
#         MagicMock(is_directory=True, name="test_directory/sub_directory2"),
#         MagicMock(is_directory=False, name="test_directory/other_directory"),
#     ]

#     filtered_paths = filter_directory_paths_adls(adls_client_mock, container_name, directory_path, directory_substring)

#     # Ensure that the expected methods were called with the correct arguments
#     adls_client_mock.get_file_system_client.assert_called_once_with(container_name)
#     adls_fs_client_mock.get_directory_client.assert_called_once_with(directory_path)
#     adls_directory_client_mock.exists.assert_called_once()
#     adls_fs_client_mock.get_paths.assert_called_once_with(directory_path)

#     # Check the filtered paths
#     expected_filtered_paths = ["test_directory/sub_directory1", "test_directory/sub_directory2"]
#     assert filtered_paths == expected_filtered_paths
