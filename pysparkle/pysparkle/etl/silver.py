# Bronze to Silver transformations.
import logging
from pathlib import Path

from pyspark.sql import SparkSession

from pysparkle.config import BRONZE_CONTAINER, SILVER_CONTAINER
from pysparkle.pyspark_utils import create_spark_session
from pysparkle.storage_utils import check_env, get_adls_directory_contents, get_adls_file_url, set_spark_properties
from pysparkle.utils import filter_csv_files

logger = logging.getLogger(__name__)


def save_files_as_delta_tables(spark: SparkSession, csv_files: list[str]) -> None:
    """Saves multiple CSV files as Delta tables in a specified schema.

    The function reads CSV files from a bronze container and writes them as Delta tables
    into a silver container.

    Args:
        spark: Spark session.
        csv_files: List of CSV files to be converted into Delta tables.
    """

    def to_delta(csv_file: str) -> None:
        input_filepath = get_adls_file_url(BRONZE_CONTAINER, csv_file)
        filename_with_no_extension = Path(input_filepath).stem
        output_filepath = get_adls_file_url(SILVER_CONTAINER, filename_with_no_extension)

        df = (
            spark.read.option("header", "true")
            .option("inferSchema", "true")
            .option("delimiter", ",")
            .csv(input_filepath)
        )

        df.write.format("delta").mode("overwrite").save(output_filepath)
        table_name = f"{SILVER_CONTAINER}.{filename_with_no_extension}"
        logger.info(f"Table {table_name} saved.")

    logger.info("Saving CSV files as delta tables...")
    for file in csv_files:
        to_delta(file)


def silver_main(dataset_name):
    logger.info("Running Silver processing...")

    spark = create_spark_session("Silver")

    check_env()
    set_spark_properties(spark)
    input_paths = get_adls_directory_contents(BRONZE_CONTAINER, dataset_name)
    csv_files = filter_csv_files(input_paths)
    save_files_as_delta_tables(spark, csv_files)

    logger.info("Finished: Silver processing.")
