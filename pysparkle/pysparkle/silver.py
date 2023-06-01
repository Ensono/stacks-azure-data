# Bronze to Silver transformations.
from pathlib import Path

from pyspark.sql import SparkSession

from pysparkle.adls_utils import get_directory_contents, set_env, set_spark_properties
from pysparkle.const import ADLS_ACCOUNT, BRONZE_CONTAINER, DATASET_NAME, SILVER_CONTAINER


def filter_csv_files(paths: list[str]) -> list[str]:
    """Returns paths with the `.csv` extension.

    Args:
        paths: List of file paths.

    Returns:
        A list of file paths that end with the `.csv` extension.
    """
    return [path for path in paths if path.endswith('.csv')]


def get_adls_url(container: str, adls_account: str, file_name: str) -> str:
    """Constructs an Azure Data Lake Storage (ADLS) URL for a specific file.

    Args:
        container: The name of the ADLS container.
        adls_account: The name of the ADLS account.
        file_name: The name of the file (including any subdirectories within the container).

    Returns:
        Full ADLS URL for the specified file.
    """
    return f'abfss://{container}@{adls_account}.dfs.core.windows.net/{file_name}'


def ensure_database_exists(spark: SparkSession, schema: str) -> None:
    """Ensures that a specific database exists in the Spark session, creating it if necessary.

    Args:
        spark: Spark session.
        schema: The name of the database/schema to ensure existence of.
    """
    if not spark.catalog.databaseExists(schema):
        spark.sql(f'CREATE DATABASE IF NOT EXISTS {schema}')
        print(f'Database {schema} has been created.')


def save_files_as_delta_tables(spark: SparkSession, csv_files: list[str]) -> None:
    """Saves multiple CSV files as Delta tables in a specified schema.

    The function reads CSV files from a bronze container and writes them as Delta tables
    into a silver container.

    Args:
        spark: Spark session.
        csv_files: List of CSV files to be converted into Delta tables.
    """
    def to_delta(csv_file: str) -> None:
        filepath = get_adls_url(BRONZE_CONTAINER, ADLS_ACCOUNT, csv_file)
        filename_with_no_extension = Path(filepath).stem
        df = spark.read.option('header', 'true')\
            .option('inferSchema', 'true')\
            .option('delimiter', ',')\
            .csv(filepath)
        table_name = f'{SILVER_CONTAINER}.{filename_with_no_extension}'
        df.write.format('delta').mode('overwrite').saveAsTable(table_name)
        print(f'Table {table_name} saved.')

    print('Saving CSV files as delta tables...')
    ensure_database_exists(spark, SILVER_CONTAINER)
    for file in csv_files:
        to_delta(file)


def silver_main():
    print('Running Silver processing...')
    spark = SparkSession \
        .builder \
        .appName('Silver') \
        .getOrCreate()

    set_env()
    set_spark_properties(spark)
    input_paths = get_directory_contents(BRONZE_CONTAINER, DATASET_NAME)
    csv_files = filter_csv_files(input_paths)
    save_files_as_delta_tables(spark, csv_files)

    print('Finished: Silver processing.')
