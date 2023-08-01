from pathlib import Path
from unittest.mock import patch

import pytest

from pysparkle.config import BRONZE_CONTAINER, SILVER_CONTAINER
from pysparkle.etl.silver import save_files_as_delta_tables
from tests.unit.conftest import TEST_CSV_DIR


@pytest.mark.parametrize(
    "csv_files,expected_columns",
    [
        (
            ["links.csv", "ratings.csv"],
            [["movieId", "imdbId", "tmdbId"], ["userId", "movieId", "rating", "timestamp"]],
        ),
    ],
)
@patch("pysparkle.etl.silver.get_adls_file_url")
def test_save_files_as_delta_tables(mock_get_adls_file_url, spark, csv_files, expected_columns, tmp_path):
    def side_effect(container, file_name):
        if container == BRONZE_CONTAINER:
            # fixed path for test input files
            return f"{TEST_CSV_DIR}/{file_name}"
        else:
            # temporary path for any test outputs
            return f"{tmp_path}/{file_name}"

    mock_get_adls_file_url.side_effect = side_effect

    save_files_as_delta_tables(spark, csv_files)

    for i, csv_file in enumerate(csv_files):
        filename_with_no_extension = Path(csv_file).stem
        expected_filepath = side_effect(SILVER_CONTAINER, filename_with_no_extension)
        df = spark.read.format("delta").load(expected_filepath)
        assert df is not None
        assert df.count() > 0
        assert df.columns == expected_columns[i]
