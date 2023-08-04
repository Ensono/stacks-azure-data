# Spark common utilities
import logging
import os
from typing import Any, Optional

from pyspark.sql import DataFrame, SparkSession

from pysparkle.utils import substitute_env_vars

logger = logging.getLogger(__name__)


def create_spark_session(app_name: str, spark_config: dict[str, Any] = None) -> SparkSession:
    """Creates a SparkSession with the specified application name or retrieves one that already exists.

    The SparkSession is configured to include Hadoop Azure and Delta Lake packages. If a SparkSession is already active,
    it will be returned instead of creating a new one.

    Args:
        app_name: Name of the Spark application.
        spark_config: A dictionary with additional Spark configuration options to set.

    Returns:
        Spark session with Delta Lake as the catalog implementation.

    """
    spark = SparkSession.getActiveSession()
    if not spark:
        logger.info("Creating Spark session...")

        config = {
            "spark.jars.packages": "org.apache.hadoop:hadoop-azure:3.3.4,io.delta:delta-core_2.12:2.4.0",
            "spark.sql.extensions": "io.delta.sql.DeltaSparkSessionExtension",
            "spark.sql.catalog.spark_catalog": "org.apache.spark.sql.delta.catalog.DeltaCatalog",
        }

        if spark_config:
            config.update(spark_config)

        spark_builder = SparkSession.builder.appName(app_name)

        for key, value in config.items():
            spark_builder = spark_builder.config(key, value)

        spark = spark_builder.getOrCreate()

        logger.info("Spark session created.")

    return spark


def read_datasource(
    spark: SparkSession, data_location: str, datasource_type: str, options: Optional[dict[str, Any]] = None
) -> DataFrame:
    """Reads the data from the given location and returns it as a dataframe.

    Args:
        spark: Spark session.
        data_location: Location of the given data asset. It can either be a path to the data file or a fully qualified
            table name, depending on the datasource type.
        datasource_type: Source system type that Spark can read from, e.g. delta, table, parquet, json, csv.
        options: Optional dictionary of options to pass to the DataFrameReader.

    Returns:
        The dataframe loaded from the datasource.

    Examples:
        If the data is stored in a file, you should provide the complete path to the file, e.g.:

        >>> read_datasource(spark, "abfss://silver@{ADLS_ACCOUNT}.dfs.core.windows.net/myfolder", "delta")
        >>> read_datasource(spark, "abfss://raw@{ADLS_ACCOUNT}.dfs.core.windows.net/myfolder/mysubfolder/*",
        ...     "parquet", {"mergeSchema": "true"})
        >>> read_datasource(spark, "abfss://raw@{ADLS_ACCOUNT}.dfs.core.windows.net/myfolder",
        ...     "csv", {"inferSchema": "true", "delimiter": ","})

        For tables with metadata managed by a data catalog, you should provide the database schema and the table name:

        >>> read_datasource(spark, "staging.movies_metadata", "table")

    """
    data_location = substitute_env_vars(data_location)

    if options is None:
        options = {}

    if datasource_type.lower() == "delta":
        return spark.read.options(**options).format("delta").load(data_location)
    else:
        source_type = getattr(spark.read.options(**options), datasource_type)
        return source_type(data_location)


def save_dataframe_as_delta(dataframe: DataFrame, output_filepath: str) -> None:
    """Saves a Spark DataFrame as a Delta table at a specified location, overwriting any existing data.

    Args:
        dataframe: Spark DataFrame to save as a Delta table.
        output_filepath: The location to write the Delta table.

    Example:
        >>> save_dataframe_as_delta(dataframe, "abfss://silver@{ADLS_ACCOUNT}.dfs.core.windows.net/mytable")

    """
    table_name = os.path.basename(output_filepath)
    logger.info(f"Saving delta table {table_name}...")
    dataframe.write.format("delta").mode("overwrite").save(output_filepath)
    logger.info(f"Saved: {output_filepath}.")


def ensure_database_exists(spark: SparkSession, schema: str) -> None:
    """Ensures that a specific database exists in the Spark session, creating it if necessary.

    Args:
        spark: Spark session.
        schema: The name of the database/schema to ensure existence of.
    """
    if not spark.catalog.databaseExists(schema):
        spark.sql(f"CREATE DATABASE IF NOT EXISTS {schema}")
        logger.info(f"Database {schema} has been created.")
