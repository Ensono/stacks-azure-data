import logging

from pyspark.sql import DataFrame
from pyspark.sql.functions import avg

from datastacks.constants import SILVER_CONTAINER_NAME, GOLD_CONTAINER_NAME
from datastacks.logger import setup_logger
from datastacks.pyspark.etl import (
    get_spark_session_for_adls,
)
from datastacks.pyspark.pyspark_utils import save_dataframe_as_delta, read_datasource
from datastacks.pyspark.storage_utils import get_adls_file_url

WORKLOAD_NAME = "gold_movies_example"
SOURCE_DATA_TYPE = "delta"
INPUT_PATH_PATTERN = "movies/{table_name}"
OUTPUT_PATH_PATTERN = "movies/{table_name}"

logger_library = "datastacks"
logger = logging.getLogger(logger_library)


def join_metadata_and_average_ratings(metadata: DataFrame, ratings: DataFrame) -> DataFrame:
    """Join movie metadata and average ratings DataFrames.

    Args:
        metadata: Input DataFrame containing movie metadata.
        ratings: Input DataFrame containing all ratings for each movie.

    Returns:
        DataFrame containing movie metadata with average ratings.
    """
    avg_ratings = ratings.groupBy("movie_id").agg(avg("rating").alias("rating")).withColumnRenamed("movie_id", "id")
    return metadata.drop(
        "belongs_to_collection", "genres", "production_companies", "production_countries", "spoken_languages"
    ).join(avg_ratings, "id", "left")


def etl_main() -> None:
    """Execute data processing and transformation jobs."""
    logger.info(f"Running {WORKLOAD_NAME} processing...")

    spark = get_spark_session_for_adls(WORKLOAD_NAME)

    logger.info(f"Reading data from {SILVER_CONTAINER_NAME} container...")
    ratings_url = get_adls_file_url(SILVER_CONTAINER_NAME, INPUT_PATH_PATTERN.format(table_name="ratings_small"))
    ratings = read_datasource(spark, ratings_url, datasource_type=SOURCE_DATA_TYPE)
    metadata_url = get_adls_file_url(SILVER_CONTAINER_NAME, INPUT_PATH_PATTERN.format(table_name="movies_metadata"))
    metadata = read_datasource(spark, metadata_url, datasource_type=SOURCE_DATA_TYPE)

    logger.info("Transforming data...")
    output_df = join_metadata_and_average_ratings(metadata, ratings)

    logger.info(f"Saving data to {GOLD_CONTAINER_NAME} container...")
    output_filepath = get_adls_file_url(
        GOLD_CONTAINER_NAME, OUTPUT_PATH_PATTERN.format(table_name="movies_ratings_agg")
    )
    save_dataframe_as_delta(spark, output_df, output_filepath, overwrite=True)

    logger.info(f"Finished: {WORKLOAD_NAME} processing.")


if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)
    etl_main()
