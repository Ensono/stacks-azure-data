# Bronze to Silver transformations.
import logging
from pathlib import Path

from pyspark.sql import SparkSession

from pysparkle.adls_utils import check_env, get_adls_file_url, get_directory_contents, \
    set_spark_properties
from pysparkle.config import BRONZE_CONTAINER, SILVER_CONTAINER

logger = logging.getLogger(__name__)


def filter_csv_files(paths: list[str]) -> list[str]:
    """Returns paths with the `.csv` extension.

    Args:
        paths: List of file paths.

    Returns:
        A list of file paths that end with the `.csv` extension.
    """
    return [path for path in paths if path.endswith('.csv')]


def ensure_database_exists(spark: SparkSession, schema: str) -> None:
    """Ensures that a specific database exists in the Spark session, creating it if necessary.

    Args:
        spark: Spark session.
        schema: The name of the database/schema to ensure existence of.
    """
    if not spark.catalog.databaseExists(schema):
        spark.sql(f'CREATE DATABASE IF NOT EXISTS {schema}')
        logger.info(f'Database {schema} has been created.')


def save_files_as_delta_tables(spark: SparkSession, csv_files: list[str]) -> None:
    """Saves multiple CSV files as Delta tables in a specified schema.

    The function reads CSV files from a bronze container and writes them as Delta tables
    into a silver container.

    Args:
        spark: Spark session.
        csv_files: List of CSV files to be converted into Delta tables.
    """
    def to_delta(csv_file: str) -> None:
        filepath = get_adls_file_url(BRONZE_CONTAINER, csv_file)
        filename_with_no_extension = Path(filepath).stem
        df = spark.read.option('header', 'true')\
            .option('inferSchema', 'true')\
            .option('delimiter', ',')\
            .csv(filepath)
        table_name = f'{SILVER_CONTAINER}.{filename_with_no_extension}'
        df.write.format('delta').mode('overwrite').saveAsTable(table_name)
        logger.info(f'Table {table_name} saved.')

    logger.info('Saving CSV files as delta tables...')
    ensure_database_exists(spark, SILVER_CONTAINER)
    for file in csv_files:
        to_delta(file)


def silver_main(dataset_name):
    logger.info('Running Silver processing...')
    spark = SparkSession \
        .builder \
        .appName('Silver') \
        .getOrCreate()

    check_env()
    set_spark_properties(spark)
    input_paths = get_directory_contents(BRONZE_CONTAINER, dataset_name)
    csv_files = filter_csv_files(input_paths)
    save_files_as_delta_tables(spark, csv_files)

    logger.info('Finished: Silver processing.')
