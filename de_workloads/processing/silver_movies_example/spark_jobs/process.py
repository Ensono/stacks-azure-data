import logging

from pyspark.sql import DataFrame
from pyspark.sql.functions import col, explode, from_json
from pyspark.sql.types import ArrayType, IntegerType, StringType, StructField, StructType

from stacks.data.constants import BRONZE_CONTAINER_NAME, SILVER_CONTAINER_NAME
from stacks.data.pyspark.etl import (
    EtlSession,
    TableTransformation,
    read_latest_rundate_data,
    transform_and_save_as_delta,
)
from stacks.data.logger import setup_logger
from stacks.data.pyspark.pyspark_utils import rename_columns_to_snake_case

WORKLOAD_NAME = "silver_movies_example"
SOURCE_DATA_TYPE = "parquet"
INPUT_PATH_PATTERN = "ingest_azure_sql_example/movies.{table_name}/v1/full/"
OUTPUT_PATH_PATTERN = "movies/{table_name}"


logger_library = "stacks.data"
logger = logging.getLogger(logger_library)


def transform_keywords(df: DataFrame) -> DataFrame:
    """Parse and flatten the keywords column from the input DataFrame.

    Args:
        df: Input DataFrame containing a 'keywords' column with JSON strings.

    Returns:
        Flattened DataFrame with 'keyword_id' and 'keyword_name' columns.

    """
    keywords_schema = ArrayType(StructType([StructField("id", IntegerType()), StructField("name", StringType())]))

    df_parsed = df.withColumn("keywords_json", from_json(col("keywords"), keywords_schema))

    df_flattened = (
        df_parsed.withColumn("keywords", explode(col("keywords_json")))
        .withColumn("keyword_id", col("keywords").getField("id"))
        .withColumn("keyword_name", col("keywords").getField("name"))
        .drop("keywords_json", "keywords")
    )

    return rename_columns_to_snake_case(df_flattened)


def transform_movies_metadata(df: DataFrame) -> DataFrame:
    """Transforms a DataFrame containing movies metadata, parsing and flattening nested JSON structures.

    Args:
        df: The input DataFrame containing movies metadata.

    Returns:
        A transformed DataFrame with parsed and flattened movie metadata fields.

    """
    # Define the schemas
    belongs_to_collection_schema = StructType(
        [
            StructField("id", IntegerType()),
            StructField("name", StringType()),
            StructField("poster_path", StringType()),
            StructField("backdrop_path", StringType()),
        ]
    )

    genre_schema = ArrayType(StructType([StructField("id", IntegerType()), StructField("name", StringType())]))

    production_companies_schema = ArrayType(
        StructType([StructField("name", StringType()), StructField("id", IntegerType())])
    )

    production_countries_schema = ArrayType(
        StructType([StructField("iso_3166_1", StringType()), StructField("name", StringType())])
    )

    spoken_languages_schema = ArrayType(
        StructType([StructField("iso_639_1", StringType()), StructField("name", StringType())])
    )

    # Convert and flatten
    df_parsed = (
        df.withColumn("belongs_to_collection", from_json(col("belongs_to_collection"), belongs_to_collection_schema))
        .withColumn("genres", from_json(col("genres"), genre_schema))
        .withColumn("production_companies", from_json(col("production_companies"), production_companies_schema))
        .withColumn("production_countries", from_json(col("production_countries"), production_countries_schema))
        .withColumn("spoken_languages", from_json(col("spoken_languages"), spoken_languages_schema))
    )

    df_exploded = (
        df_parsed.withColumn("genre", explode(col("genres")))
        .withColumn("production_company", explode(col("production_companies")))
        .withColumn("production_country", explode(col("production_countries")))
        .withColumn("spoken_language", explode(col("spoken_languages")))
        .drop("genres", "production_companies", "production_countries", "spoken_languages")
    )

    df_final = (
        df_exploded.withColumn("genre_id", col("genre.id"))
        .withColumn("genre_name", col("genre.name"))
        .withColumn("production_company_name", col("production_company.name"))
        .withColumn("production_country_iso", col("production_country.iso_3166_1"))
        .withColumn("spoken_language_iso", col("spoken_language.iso_639_1"))
        .drop("genre", "production_company", "production_country", "spoken_language")
    )

    return rename_columns_to_snake_case(df_final)


def etl_main() -> None:
    """Execute data processing and transformation jobs."""
    logger.info(f"Running {WORKLOAD_NAME} processing...")

    etl_session = EtlSession(WORKLOAD_NAME)
    spark_session = etl_session.spark_session
    adls_client = etl_session.adls_client

    tables = [
        TableTransformation("keywords", transform_keywords),
        TableTransformation("links", rename_columns_to_snake_case),
        TableTransformation("ratings_small", rename_columns_to_snake_case),
        TableTransformation("movies_metadata", transform_movies_metadata),
    ]

    for table in tables:
        df = read_latest_rundate_data(
            spark_session,
            adls_client,
            BRONZE_CONTAINER_NAME,
            INPUT_PATH_PATTERN.format(table_name=table.table_name),
            datasource_type=SOURCE_DATA_TYPE,
        )

        output_path = OUTPUT_PATH_PATTERN.format(table_name=table.table_name)

        transform_and_save_as_delta(
            spark_session, adls_client, df, table.transformation_function, SILVER_CONTAINER_NAME, output_path
        )

    logger.info(f"Finished: {WORKLOAD_NAME} processing.")


if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)
    etl_main()
