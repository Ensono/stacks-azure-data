# Bronze to Silver transformations.
import logging
from pathlib import Path
from typing import Any, Optional

from pyspark.sql import SparkSession

from pysparkle.config import DEFAULT_BRONZE_CONTAINER, DEFAULT_SILVER_CONTAINER
from pysparkle.pyspark_utils import get_spark_session, read_datasource, save_dataframe_as_delta
from pysparkle.storage_utils import check_env, get_adls_file_url, set_spark_properties

logger = logging.getLogger(__name__)


def save_files_as_delta_tables(
    spark: SparkSession,
    input_files: list[str],
    datasource_type: str,
    bronze_container: str = DEFAULT_BRONZE_CONTAINER,
    silver_container: str = DEFAULT_SILVER_CONTAINER,
    spark_read_options: Optional[dict[str, Any]] = None,
) -> None:
    """Saves multiple data files as Delta tables.

    The function reads input files in a given format from a bronze container and writes them as Delta tables
    into a silver container.

    Args:
        spark: Spark session.
        input_files: List of file paths within the bronze container to be converted into Delta tables.
        datasource_type: Source format that Spark can read from, e.g. delta, table, parquet, json, csv.
        bronze_container: Name of the bronze layer container.
        silver_container: Name of the silver layer container.
        spark_read_options: Options to pass to the DataFrameReader.
    """
    logger.info("Saving input files as delta tables...")
    for file in input_files:
        filepath = get_adls_file_url(bronze_container, file)
        df = read_datasource(spark, filepath, datasource_type, spark_read_options)
        filename_with_no_extension = Path(filepath).stem
        output_filepath = get_adls_file_url(silver_container, filename_with_no_extension)
        save_dataframe_as_delta(df, output_filepath)


def get_spark_session_for_adls(app_name: str, spark_config: dict[str, Any] = None) -> SparkSession:
    """Retrieve a SparkSession configured for Azure Data Lake Storage access.

    This function first checks that the required environment variables for ADLS are set. If they are, it then gets
    (or creates) a SparkSession and configures its properties to allow for ADLS access using the set environment
    variables.

    Args:
        app_name: Name of the Spark application.
        spark_config: A dictionary with additional Spark configuration options to set.

    Returns:
        Configured Spark session for ADLS access.

    Raises:
        EnvironmentError: If any of the required environment variables for ADLS access are not set.

    """
    check_env()
    spark = get_spark_session(app_name, spark_config)
    set_spark_properties(spark)
    return spark
