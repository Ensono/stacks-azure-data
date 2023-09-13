import logging

from pysparkle.config import CONFIG_CONTAINER
from pysparkle.data_quality.main import data_quality_main
from pysparkle.logger import setup_logger

CONFIG_PATH = "ingest/Ingest_QA_DLP_Dataset/data_quality/ingest_dq.json"

logger_library = "pysparkle"

if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)
    data_quality_main(config_path=CONFIG_PATH, container_name=CONFIG_CONTAINER)
