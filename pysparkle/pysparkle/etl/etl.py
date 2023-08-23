# Bronze to Silver transformations.
import logging
from pathlib import Path
from typing import Any, Optional

from dateutil.parser import isoparse
from pyspark.sql import DataFrame, SparkSession

from pysparkle.pyspark_utils import get_spark_session, read_datasource, save_dataframe_as_delta
from pysparkle.storage_utils import check_env, get_adls_directory_contents, get_adls_file_url, set_spark_properties

logger = logging.getLogger(__name__)


def save_files_as_delta_tables(
    spark: SparkSession,
    input_files: list[str],
    datasource_type: str,
    source_container: str,
    target_container: str,
    spark_read_options: Optional[dict[str, Any]] = None,
) -> None:
    """Saves multiple data files as Delta tables.

    The function reads input files in a given format from a bronze container and writes them as Delta tables
    into a silver container.

    Args:
        spark: Spark session.
        input_files: List of file paths within the bronze container to be converted into Delta tables.
        datasource_type: Source format that Spark can read from, e.g. delta, table, parquet, json, csv.
        source_container: Name of the source container in ADLS.
        target_container: Name of the destination container in ADLS.
        spark_read_options: Options to pass to the DataFrameReader.
    """
    logger.info("Saving input files as delta tables...")
    for file in input_files:
        filepath = get_adls_file_url(source_container, file)
        df = read_datasource(spark, filepath, datasource_type, spark_read_options)
        filename_with_no_extension = Path(filepath).stem
        output_filepath = get_adls_file_url(target_container, filename_with_no_extension)
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


def read_latest_rundate_data(
    spark: SparkSession, container_name: str, datasource_path: str, datasource_type: str
) -> DataFrame:
    """Reads the most recent data, based on rundate, from an ADLS location and returns it as a dataframe.

    The function identifies the latest rundate by parsing directory names in the given path and then reads the
    corresponding data. The rundate directories should follow the format: "rundate=<date_string_in_ISO-8601>",
    e.g. "rundate=YYYY-MM-DDTHH:MM:SS" or "rundate=YYYY-MM-DDTHHMMSS.FFFFFFZ".

    Args:
        spark: Spark session.
        container_name: Name of the ADLS container.
        datasource_path: Directory path within the ADLS container where rundate directories are located.
        datasource_type: Source system type that Spark can read from, e.g. delta, table, parquet, json, csv.

    Returns:
        The dataframe loaded from the datasource with the most recent rundate, with metadata columns dropped.

    """
    logger.info(f"Reading dataset: {datasource_path}")
    dirname_prefix = "rundate="
    metadata_columns = ["meta_ingestion_datetime", "meta_ingestion_pipeline", "meta_ingestion_run_id"]
    directories = get_adls_directory_contents(container_name, datasource_path, recursive=False)
    rundates = [directory.split(dirname_prefix)[1] for directory in directories]
    most_recent_rundate = max(rundates, key=isoparse)
    logger.info(f"Processing rundate: {most_recent_rundate}")
    latest_path = datasource_path + dirname_prefix + most_recent_rundate
    dataset_url = get_adls_file_url(container_name, latest_path)
    return read_datasource(spark, dataset_url, datasource_type).drop(*metadata_columns)
