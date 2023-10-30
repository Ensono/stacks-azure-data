import logging

from stacks.data.constants import CONFIG_CONTAINER_NAME
from stacks.data.pyspark.data_quality.main import data_quality_main
from stacks.data.pyspark.etl import get_data_factory_param
from stacks.data.logger import setup_logger

CONFIG_PATH = "ingest/ingest_azure_sql_example/data_quality/data_quality_config.json"

logger_library = "stacks.data"

if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)

    # Get parameters passed from Data Factory Python activity
    run_id = get_data_factory_param(1, "default_run_id")
    test_flag = get_data_factory_param(2, False, True)
    test_output_path = get_data_factory_param(3)

    # Run Data Quality
    data_quality_main(
        config_path=CONFIG_PATH,
        container_name=CONFIG_CONTAINER_NAME,
        test_flag=test_flag,
        test_run_id=run_id,
        test_data_adls_path=test_output_path,
    )
