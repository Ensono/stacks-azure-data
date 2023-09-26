from ...spark_jobs.process import average_ratings, join_metadata_and_ratings


def test_average_ratings(spark):
    # test average_ratings function
    input_data = [
        (1, 1.0),
        (1, 2.0),
        (2, 3.0),
        (2, 4.0),
        (2, 5.0),
        (3, 6.0),
        (3, 7.0),
        (3, 8.0),
        (3, 9.0),
        (4, 10.0),
    ]
    input_columns = ["movie_id", "rating"]
    input_df = spark.createDataFrame(input_data, input_columns)

    expected_data = [
        (1, 1.5),
        (2, 4.0),
        (3, 7.5),
        (4, 10.0),
    ]
    expected_columns = ["id", "rating"]
    expected_df = spark.createDataFrame(expected_data, expected_columns)

    actual_df = average_ratings(input_df)

    assert actual_df.collect() == expected_df.collect()


def test_join_metadata_and_ratings(spark):
    # test join_metadata_and_ratings function
    input_metadata = [
        (1, "title1"),
        (2, "title2"),
        (3, "title3"),
        (5, "title5"),
    ]
    input_metadata_columns = ["id", "title"]
    input_metadata_df = spark.createDataFrame(input_metadata, input_metadata_columns)

    input_avg_ratings = [
        (1, 1.5),
        (2, 4.0),
        (3, 7.5),
        (4, 10.0),
    ]
    input_avg_ratings_columns = ["id", "rating"]
    input_avg_ratings_df = spark.createDataFrame(input_avg_ratings, input_avg_ratings_columns)

    expected_data = [
        (1, "title1", 1.5),
        (2, "title2", 4.0),
        (3, "title3", 7.5),
        (5, "title5", None),
    ]
    expected_columns = ["id", "title", "rating"]
    expected_df = spark.createDataFrame(expected_data, expected_columns)

    actual_df = join_metadata_and_ratings(input_metadata_df, input_avg_ratings_df)

    assert actual_df.collect() == expected_df.collect()
