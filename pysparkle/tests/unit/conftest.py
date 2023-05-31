import os
from pathlib import Path
from unittest.mock import MagicMock, PropertyMock, patch

from pyspark.sql import SparkSession
from pytest import fixture

TEST_DATA_DIR = Path(__file__).parent.resolve() / 'data'


@fixture(scope='session')
def spark():
    spark = (
        SparkSession.builder
        .master('local')
        .appName('pysparkle-test')
        .getOrCreate()
    )
    yield spark
    spark.stop()


@fixture
def mock_adls_client():
    with patch('pysparkle.adls_utils.DataLakeServiceClient') as mock_DataLakeServiceClient:
        mock_paths = [MagicMock(name=file) for file in os.listdir(TEST_DATA_DIR)]
        for mock_path, filename in zip(mock_paths, os.listdir(TEST_DATA_DIR)):
            type(mock_path).name = PropertyMock(return_value=filename)
        mock_file_system_client = MagicMock()
        mock_file_system_client.get_paths.return_value = mock_paths
        mock_DataLakeServiceClient.return_value.get_file_system_client.return_value = mock_file_system_client
        yield mock_DataLakeServiceClient
