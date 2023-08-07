# Bronze to Silver transformations.
import logging
from pathlib import Path
from typing import Any, Optional

from pyspark.sql import SparkSession

from pysparkle.config import BRONZE_CONTAINER, SILVER_CONTAINER
from pysparkle.pyspark_utils import create_spark_session, read_datasource, save_dataframe_as_delta
from pysparkle.storage_utils import check_env, get_adls_directory_contents, get_adls_file_url, set_spark_properties
from pysparkle.utils import filter_files_by_extension

logger = logging.getLogger(__name__)


def save_files_as_delta_tables(
    spark: SparkSession,
    input_files: list[str],
    datasource_type: str,
    spark_read_options: Optional[dict[str, Any]] = None,
) -> None:
    """Saves multiple data files as Delta tables.

    The function reads input files in a given format from a bronze container and writes them as Delta tables
    into a silver container.

    Args:
        spark: Spark session.
        input_files: List of file paths within the bronze container to be converted into Delta tables.
        datasource_type: Source format that Spark can read from, e.g. delta, table, parquet, json, csv.
        spark_read_options: Options to pass to the DataFrameReader.
    """
    logger.info("Saving input files as delta tables...")
    for file in input_files:
        filepath = get_adls_file_url(BRONZE_CONTAINER, file)
        df = read_datasource(spark, filepath, datasource_type, spark_read_options)
        filename_with_no_extension = Path(filepath).stem
        output_filepath = get_adls_file_url(SILVER_CONTAINER, filename_with_no_extension)
        save_dataframe_as_delta(df, output_filepath)


def silver_main(dataset_name):
    logger.info("Running Silver processing...")
    check_env()

    spark = create_spark_session("Silver")

    datasource_type = "csv"
    set_spark_properties(spark)
    input_paths = get_adls_directory_contents(BRONZE_CONTAINER, dataset_name)
    input_paths = filter_files_by_extension(input_paths, extension=datasource_type)
    spark_read_options = {"header": "true", "inferSchema": "true", "delimiter": ","}
    save_files_as_delta_tables(spark, input_paths, datasource_type, spark_read_options)

    logger.info("Finished: Silver processing.")
