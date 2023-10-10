import logging

from datastacks.constants import CONFIG_CONTAINER_NAME
from datastacks.pyspark.etl import get_data_factory_param
from datastacks.pyspark.data_quality.main import data_quality_main
from datastacks.logger import setup_logger

CONFIG_PATH = "ingest/ingest_azure_sql_example/data_quality/ingest_dq.json"

logger_library = "datastacks"

if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)

    # Get parameters passed from Data Factory Python activity
    run_id = get_data_factory_param(1, "default_run_id")
    test_flag = get_data_factory_param(2, False, True)

    # Run Data Quality
    data_quality_main(CONFIG_PATH, CONFIG_CONTAINER_NAME, test_flag, run_id)
