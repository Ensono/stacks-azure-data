import logging

from pyspark.sql import SparkSession

from pysparkle.adls_utils import check_env, set_spark_properties
from pysparkle.data_quality.data_quality_utils import (
    create_datasource_context,
    create_expectation_suite,
    execute_validations,
)
from pysparkle.config_utils import load_config_as_dict

logger = logging.getLogger(__name__)


def data_quality_main(config_path):
    dq_conf = load_config_as_dict(config_path)
    logger.info(f"Running Data Quality processing for {dq_conf['dataset_name']}...")

    spark = SparkSession.builder.appName(
        f'DataQuality-{dq_conf["container_name"]}-{dq_conf["dataset_name"]}'
    ).getOrCreate()

    check_env()
    set_spark_properties(spark)

    for datasource in dq_conf["datasource_config"]:
        logger.info(f"Running data quality processing for {datasource['datasource_name']}")

        source_type = getattr(spark.read, datasource["datasource_type"])
        df = source_type(datasource["data_location"])

        gx_context = create_datasource_context(datasource["datasource_name"], dq_conf['gx_directory_path'])

        gx_context = create_expectation_suite(gx_context, datasource)

        results = execute_validations(gx_context, datasource, df)

        logger.info(f"Finished data quality for {datasource['datasource_name']}")
        logger.info(results)

    logger.info("Finished: Data Quality processing.")
