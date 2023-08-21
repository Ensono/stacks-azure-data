import logging

from pysparkle.etl.etl import get_spark_session_for_adls, save_files_as_delta_tables
from pysparkle.logger import setup_logger
from pysparkle.storage_utils import get_adls_directory_contents
from pysparkle.utils import filter_files_by_extension


BRONZE_CONTAINER = "raw"
SILVER_CONTAINER = "staging"

logger_library = "pysparkle"
logger = logging.getLogger(logger_library)


def etl_main(dataset_name: str) -> None:
    """Execute the Silver processing for a given dataset.

    This function assumes that datasets in the bronze container are in CSV format and uses specific Spark read options.

    Args:
        dataset_name: Name of the dataset to process.

    """
    logger.info("Running Silver processing...")

    spark = get_spark_session_for_adls("Silver")

    datasource_type = "csv"
    input_paths = get_adls_directory_contents(BRONZE_CONTAINER, dataset_name)
    input_paths = filter_files_by_extension(input_paths, extension=datasource_type)
    spark_read_options = {"header": "true", "inferSchema": "true", "delimiter": ","}
    save_files_as_delta_tables(
        spark, input_paths, datasource_type, BRONZE_CONTAINER, SILVER_CONTAINER, spark_read_options
    )

    logger.info("Finished: Silver processing.")


if __name__ == "__main__":
    setup_logger(name=logger_library, log_level=logging.INFO)
    etl_main(dataset_name="movies_dataset")
