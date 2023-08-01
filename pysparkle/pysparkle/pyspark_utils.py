# Spark common utilities
import logging

from pyspark.sql import SparkSession

logger = logging.getLogger(__name__)


def create_spark_session(app_name: str) -> SparkSession:
    """Creates a SparkSession with the specified application name or retrieves one that already exists.

    The SparkSession is configured to include Hadoop Azure and Delta Lake packages. If a SparkSession is already active,
    it will be returned instead of creating a new one.

    Args:
        app_name: Name of the Spark application.

    Returns:
        Spark session with Delta Lake as the catalog implementation.

    """
    spark = SparkSession.getActiveSession()
    if not spark:
        logger.info("Creating Spark session...")
        spark = (
            SparkSession.builder.appName(app_name)
            .config(
                "spark.jars.packages",
                ("org.apache.hadoop:hadoop-azure:3.3.4," "io.delta:delta-core_2.12:2.4.0"),
            )
            .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
            .config(
                "spark.sql.catalog.spark_catalog",
                "org.apache.spark.sql.delta.catalog.DeltaCatalog",
            )
            .getOrCreate()
        )
        logger.info("Spark session created.")

    return spark


def ensure_database_exists(spark: SparkSession, schema: str) -> None:
    """Ensures that a specific database exists in the Spark session, creating it if necessary.

    Args:
        spark: Spark session.
        schema: The name of the database/schema to ensure existence of.
    """
    if not spark.catalog.databaseExists(schema):
        spark.sql(f"CREATE DATABASE IF NOT EXISTS {schema}")
        logger.info(f"Database {schema} has been created.")
