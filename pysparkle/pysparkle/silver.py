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


def save_files_as_delta_tables(spark: SparkSession, csv_files: list[str]) -> None:
    """Saves multiple CSV files as Delta tables in a specified schema.

    The function reads CSV files from a bronze container and writes them as Delta tables
    into a silver container.

    Args:
        spark: Spark session.
        csv_files: List of CSV files to be converted into Delta tables.
    """
    def to_delta(csv_file: str) -> None:
        filepath = f'abfss://{BRONZE_CONTAINER}@{ADLS_ACCOUNT}.dfs.core.windows.net/{csv_file}'
        filename_with_no_extension = Path(filepath).stem
        df = spark.read.option('header', 'true')\
            .option('inferSchema', 'true')\
            .option('delimiter', ',')\
            .csv(filepath)
        table_name = f'{SILVER_CONTAINER}.{filename_with_no_extension}'
        df.write.format('delta').mode('overwrite').saveAsTable(table_name)
        print(f'Table {table_name} saved.')

    print('Saving CSV files as delta tables...')
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
