import logging
import sys

from datastacks.constants import CONFIG_CONTAINER_NAME
from datastacks.pyspark.data_quality.config import Config
from datastacks.pyspark.data_quality.utils import (
    add_expectation_suite,
    create_datasource_context,
    execute_validations,
    publish_quality_results_table,
)
from datastacks.pyspark.pyspark_utils import get_spark_session, read_datasource
from datastacks.pyspark.storage_utils import check_env, load_json_from_blob, set_spark_properties
from datastacks.pyspark.utils import substitute_env_vars

logger = logging.getLogger(__name__)


def data_quality_main(config_path: str, container_name: str = CONFIG_CONTAINER_NAME):
    """Executes data quality checks based on the provided configuration.

    Args:
        config_path: Path to a JSON config inside an Azure Blob container.
        container_name: Name of the container for storing configurations.

    Raises:
        EnvironmentError: if any of the required environment variables for ADLS access are not set.

    """
    check_env()

    data_factory_run_id = sys.argv[1]
    data_factory_test_flag = sys.argv[2]

    dq_conf_dict = load_json_from_blob(container_name, config_path)
    dq_conf = Config.parse_obj(dq_conf_dict)
    logger.info(f"Running Data Quality processing for dataset: {dq_conf.dataset_name}...")

    spark = get_spark_session(f"DataQuality-{dq_conf.dataset_name}")

    set_spark_properties(spark)

    dq_output_path = substitute_env_vars(dq_conf.dq_output_path)

    for datasource in dq_conf.datasource_config:
        logger.info(f"Checking DQ for datasource: {datasource.datasource_name}...")

        df = read_datasource(spark, datasource.data_location, datasource.datasource_type)

        gx_context = create_datasource_context(datasource.datasource_name, dq_conf.gx_directory_path)
        gx_context = add_expectation_suite(gx_context, datasource)

        validation_result = execute_validations(gx_context, datasource, df)
        results = validation_result.results

        data_quality_run_date = validation_result.meta["run_id"].run_time

        if data_factory_test_flag == "True":
            full_dq_output_path = (
                f"{dq_output_path}automated_tests/{data_factory_run_id}/{datasource.datasource_name}_dq/"
            )
        else:
            full_dq_output_path = f"{dq_output_path}{datasource.datasource_name}_dq/"

        failed_validations = publish_quality_results_table(
            spark, full_dq_output_path, datasource.datasource_name, results, data_quality_run_date
        )

        if not failed_validations.rdd.isEmpty():
            logger.info(f"Checking {datasource.datasource_name}, {failed_validations.count()} validations failed.")
        else:
            logger.info(f"Checking {datasource.datasource_name}, All validations passed.")

    logger.info("Finished: Data Quality processing.")
