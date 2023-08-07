import pytest
from pyspark.sql import Row

from pysparkle.pyspark_utils import ensure_database_exists, read_datasource, save_dataframe_as_delta


@pytest.mark.parametrize(
    "file_format,read_options,write_options",
    [
        ("delta", {}, {}),
        ("parquet", {}, {}),
        ("json", {}, {}),
        ("csv", {"header": "true", "inferSchema": "true"}, {"header": "true"}),
    ],
)
def test_read_datasource(spark, tmp_path, file_format, read_options, write_options):
    sample_data = [Row(col_a=1, col_b=4, col_c="p"), Row(col_a=2, col_b=5, col_c="q"), Row(col_a=3, col_b=6, col_c="r")]

    df = spark.createDataFrame(sample_data)

    output_path = str(tmp_path / f"testfile.{file_format}")

    df.write.options(**write_options).format(file_format).save(output_path)

    df_read = read_datasource(spark, output_path, file_format, read_options)

    assert df_read.count() == len(sample_data)  # same number of rows
    assert len(df_read.columns) == len(sample_data[0])  # same number of columns


def test_read_datasource_as_table(spark):
    sample_data = [Row(col_a=1, col_b=4, col_c="p"), Row(col_a=2, col_b=5, col_c="q"), Row(col_a=3, col_b=6, col_c="r")]

    df = spark.createDataFrame(sample_data)

    table_name = "test_table"
    df.write.format("delta").mode("overwrite").saveAsTable(table_name)

    df_read = read_datasource(spark, table_name, "table")

    assert df_read.count() == len(sample_data)  # same number of rows
    assert len(df_read.columns) == len(sample_data[0])  # same number of columns


def test_save_dataframe_as_delta(spark, tmp_path):
    dataframe = spark.createDataFrame([(1, "Alice"), (2, "Bob")], ["Id", "Name"])
    output_path = str(tmp_path)

    save_dataframe_as_delta(dataframe, output_path)

    loaded_dataframe = spark.read.format("delta").load(output_path)

    assert loaded_dataframe.count() == 2
    assert loaded_dataframe.columns == ["Id", "Name"]


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
