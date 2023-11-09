from pytest import fixture

from stacks.data.pyspark.pyspark_utils import get_spark_session


@fixture(scope="session")
def spark(tmp_path_factory):
    """Spark session fixture with a temporary directory as a Spark warehouse."""
    temp_dir = tmp_path_factory.mktemp("spark-warehouse")
    spark_config = {"spark.sql.warehouse.dir": temp_dir}
    spark = get_spark_session("gold_movies_example", spark_config)

    yield spark

    spark.stop()
