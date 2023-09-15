import logging

from datastacks.pyspark.config import CONFIG_CONTAINER
from datastacks.pyspark.data_quality.main import data_quality_main
from datastacks.pyspark.logger import setup_logger

CONFIG_PATH = "ingest/Ingest_AzureSql_Example/data_quality/ingest_dq.json"

logger_library = "pysparkle"

if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)
    data_quality_main(config_path=CONFIG_PATH, container_name=CONFIG_CONTAINER)
