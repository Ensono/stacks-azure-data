import logging

from pyspark.sql import DataFrame
from pyspark.sql.functions import avg

from datastacks.logger import setup_logger
from datastacks.pyspark.etl import (
    get_spark_session_for_adls,
)
from datastacks.pyspark.pyspark_utils import save_dataframe_as_delta, read_datasource
from datastacks.pyspark.storage_utils import get_adls_file_url

WORKLOAD_NAME = "gold_movies_example"
SILVER_CONTAINER = "staging"
GOLD_CONTAINER = "curated"
SOURCE_DATA_TYPE = "delta"
INPUT_PATH_PATTERN = "movies/{table_name}"
OUTPUT_PATH_PATTERN = "movies/{table_name}"

logger_library = "pysparkle"
logger = logging.getLogger(logger_library)


def average_ratings(ratings: DataFrame) -> DataFrame:
    """Calculate the average rating for each movie.

    Args:
        ratings: Input DataFrame containing movie ratings.

    Returns:
        DataFrame with average ratings for each movie.
    """
    return ratings.groupBy("movie_id").agg(avg("rating").alias("rating")).withColumnRenamed("movie_id", "id")


def join_metadata_and_ratings(metadata: DataFrame, avg_ratings: DataFrame) -> DataFrame:
    """Join movie metadata and average ratings DataFrames.

    Args:
        metadata: Input DataFrame containing movie metadata.
        avg_ratings: Input DataFrame containing average ratings for each movie.

    Returns:
        DataFrame containing movie metadata with average ratings.
    """
    return metadata.join(avg_ratings, "id", "left")


def etl_main() -> None:
    """Execute data processing and transformation jobs."""
    logger.info(f"Running {WORKLOAD_NAME} processing...")

    spark = get_spark_session_for_adls(WORKLOAD_NAME)

    def read_data(table_name: str) -> DataFrame:
        table_url = get_adls_file_url(SILVER_CONTAINER, INPUT_PATH_PATTERN.format(table_name=table_name))
        return read_datasource(
            spark,
            table_url,
            datasource_type=SOURCE_DATA_TYPE,
        )

    logger.info(f"Reading data from {SILVER_CONTAINER} container...")
    ratings = read_data("ratings_small")
    metadata = read_data("movies_metadata")

    logger.info("Transforming data...")
    avg_ratings = average_ratings(ratings)
    output_df = join_metadata_and_ratings(metadata, avg_ratings)

    logger.info(f"Saving data to {GOLD_CONTAINER} container...")
    output_filepath = get_adls_file_url(GOLD_CONTAINER, "movies")
    save_dataframe_as_delta(spark, output_df, output_filepath, overwrite=True)

    logger.info(f"Finished: {WORKLOAD_NAME} processing.")


if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)
    etl_main()
