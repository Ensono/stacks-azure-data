import logging

from datastacks.constants import CONFIG_CONTAINER_NAME
from datastacks.pyspark.data_quality.main import data_quality_main
from datastacks.logger import setup_logger

CONFIG_PATH = "ingest/ingest_azure_sql_example/data_quality/ingest_dq.json"

logger_library = "datastacks"

if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)
    data_quality_main(config_path=CONFIG_PATH, container_name=CONFIG_CONTAINER_NAME)
