from pyspark.sql import SparkSession

from pysparkle.adls_utils import set_env, set_spark_properties
from pysparkle.data_quality.data_quality_utils import create_datasource_config, create_expectation_suite, \
execute_validations

def data_quality_main(DQ_conf):
    dataset_name = DQ_conf["dataset_name"]
    print("Running Data Quality processing...")
    spark = SparkSession.builder.appName(
        f'Data Quality {DQ_conf["container_name"]} {dataset_name}'
    ).getOrCreate()

    set_env()
    set_spark_properties(spark)

    table_name = f'{DQ_conf["container_name"]}.{dataset_name}'
    dm_data = spark.read.table(table_name)
    gx_dataframe = create_datasource_config(
        DQ_conf["dataset_name"], DQ_conf["expectation_suite_name"]
    )

    gx_dataframe = create_expectation_suite(gx_dataframe, DQ_conf)

    results = execute_validations(gx_dataframe, DQ_conf, dm_data)
    print(results)

    print("Finished: Data Quality processing.")