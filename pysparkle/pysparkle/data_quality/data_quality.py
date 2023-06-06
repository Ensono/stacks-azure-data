import logging

from pyspark.sql import SparkSession

from pysparkle.adls_utils import set_env, set_spark_properties
from pysparkle.data_quality.data_quality_utils import (
    create_datasource_context,
    create_expectation_suite,
    execute_validations,
)

logger = logging.getLogger(__name__)


def data_quality_main(dq_conf):
    dataset_name = dq_conf["dataset_name"]

    logger.info("Running Data Quality processing...")

    spark = SparkSession.builder.appName(
        f'DataQuality-{dq_conf["container_name"]}-{dataset_name}'
    ).getOrCreate()

    set_env()
    set_spark_properties(spark)

    table_name = f'{dq_conf["container_name"]}.{dataset_name}'
    df = spark.read.table(table_name)
    gx_context = create_datasource_context(dq_conf["dataset_name"], dq_conf['gx_directory_path'])

    gx_context = create_expectation_suite(gx_context, dq_conf)

    results = execute_validations(gx_context, dq_conf, df)

    logger.info(results)

    logger.info("Finished: Data Quality processing.")
