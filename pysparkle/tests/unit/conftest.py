import os
import uuid
from pathlib import Path
from unittest.mock import MagicMock, PropertyMock, patch

from pyspark.sql import SparkSession
from pytest import fixture

TEST_DATA_DIR = Path(__file__).parent.resolve() / "data"


@fixture(scope="session")
def spark(tmp_path_factory):
    """Spark session fixture with a temporary directory as a Spark warehouse."""
    temp_dir = tmp_path_factory.mktemp("spark-warehouse")
    spark = (
        SparkSession.builder.master("local")
        .appName("pysparkle-test")
        .config("spark.jars.packages", "io.delta:delta-core_2.12:2.4.0")
        .config("spark.sql.warehouse.dir", temp_dir)
        .config(
            "spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog"
        )
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .getOrCreate()
    )
    yield spark

    spark.stop()


@fixture
def mock_adls_client():
    with patch("pysparkle.storage_utils.DataLakeServiceClient") as mock_DataLakeServiceClient:
        mock_paths = [MagicMock(name=file) for file in os.listdir(TEST_DATA_DIR)]
        for mock_path, filename in zip(mock_paths, os.listdir(TEST_DATA_DIR)):
            type(mock_path).name = PropertyMock(return_value=filename)
        mock_file_system_client = MagicMock()
        mock_file_system_client.get_paths.return_value = mock_paths
        mock_DataLakeServiceClient.return_value.get_file_system_client.return_value = (
            mock_file_system_client
        )
        yield mock_DataLakeServiceClient


@fixture
def random_db_name():
    return f"db_{uuid.uuid4().hex}"


@fixture
def db_schema(spark, random_db_name):
    """Creates a database with a unique name and drops it after the test."""
    spark.sql(f"CREATE DATABASE {random_db_name}")

    yield random_db_name

    spark.sql(f"DROP DATABASE IF EXISTS {random_db_name} CASCADE")
