from unittest.mock import patch

import pytest

from pysparkle.etl.silver import *
from tests.unit.conftest import TEST_CSV_DIR


def test_filter_csv_files():
    paths = [
        "test1.csv",
        "test2.txt",
        "test3.csv",
        "test4.doc",
        "test5.pdf",
        "test6",
        "test7/csv",
    ]
    expected = ["test1.csv", "test3.csv"]
    assert filter_csv_files(paths) == expected


def test_ensure_database_exists(spark, db_schema):
    # Ensure an existing database remains accessible
    assert spark.catalog.databaseExists(db_schema)
    ensure_database_exists(spark, db_schema)
    assert spark.catalog.databaseExists(db_schema)

    spark.sql(f"DROP DATABASE {db_schema}")

    # Ensure a database is recreated
    assert not spark.catalog.databaseExists(db_schema)
    ensure_database_exists(spark, db_schema)
    assert spark.catalog.databaseExists(db_schema)


@pytest.mark.parametrize(
    "csv_files,expected_columns",
    [
        (
            ["links.csv", "ratings.csv"],
            [
                ["movieId", "imdbId", "tmdbId"],
                ["userId", "movieId", "rating", "timestamp"],
            ],
        ),
    ],
)
@patch("pysparkle.etl.silver.get_adls_file_url")
def test_save_files_as_delta_tables(
    mock_get_adls_file_url, spark, csv_files, expected_columns
):
    def side_effect(container, file_name):
        return f"{TEST_CSV_DIR}/{file_name}"

    mock_get_adls_file_url.side_effect = side_effect

    save_files_as_delta_tables(spark, csv_files)

    for i, csv_file in enumerate(csv_files):
        filename_with_no_extension = Path(csv_file).stem
        table_name = f"{SILVER_CONTAINER}.{filename_with_no_extension}"
        df = spark.read.table(table_name)
        assert df is not None
        assert df.count() > 0
        assert df.columns == expected_columns[i]
