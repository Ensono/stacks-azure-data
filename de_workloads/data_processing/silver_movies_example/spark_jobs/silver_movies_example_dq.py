import logging

from pysparkle.config import CONFIG_CONTAINER
from pysparkle.data_quality.main import data_quality_main
from pysparkle.logger import setup_logger

CONFIG_PATH = "data_processing/silver_movies_example/data_quality/silver_movies_example_dq.json"

logger_library = "pysparkle"


if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)
    data_quality_main(config_path=CONFIG_PATH, container_name=CONFIG_CONTAINER)
