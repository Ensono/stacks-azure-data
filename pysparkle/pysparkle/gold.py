# Silver to Gold transformations.
from operator import add
from random import random

from pyspark.sql import SparkSession


def gold_main(partitions: int = 2):
    print('Running the Gold command')
    print(f'Partitions parameter: {partitions}')
    spark = SparkSession \
        .builder \
        .appName('Gold') \
        .getOrCreate()

    n = 100000 * partitions

    def f(_: int) -> float:
        x = random() * 2 - 1
        y = random() * 2 - 1
        return 1 if x ** 2 + y ** 2 <= 1 else 0

    count = spark.sparkContext.parallelize(range(1, n + 1), partitions).map(f).reduce(add)
    print('Pi is roughly %f' % (4.0 * count / n))
