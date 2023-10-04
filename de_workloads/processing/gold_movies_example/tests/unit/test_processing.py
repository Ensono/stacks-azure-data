from ...spark_jobs.process import join_metadata_and_average_ratings


def test_join_metadata_and_average_ratings(spark):
    input_ratings = [
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
    input_ratings_columns = ["movie_id", "rating"]
    input_ratings_df = spark.createDataFrame(input_ratings, input_ratings_columns)

    input_metadata = [
        (1, "title1", "collection1", "genre1", "productionCompany1", "country1", "language1"),
        (2, "title2", "collection2", "genre2", "productionCompany2", "country2", "language2"),
        (3, "title3", "collection3", "genre3", "productionCompany3", "country3", "language3"),
        (5, "title5", "collection5", "genre5", "productionCompany5", "country5", "language5"),
    ]
    input_metadata_columns = [
        "id",
        "title",
        "belongs_to_collection",
        "genres",
        "production_companies",
        "production_countries",
        "spoken_languages",
    ]
    input_metadata_df = spark.createDataFrame(input_metadata, input_metadata_columns)

    expected_data = [
        (1, "title1", 1.5),
        (2, "title2", 4.0),
        (3, "title3", 7.5),
        (5, "title5", None),
    ]
    expected_columns = ["id", "title", "rating"]
    expected_df = spark.createDataFrame(expected_data, expected_columns)

    actual_df = join_metadata_and_average_ratings(input_metadata_df, input_ratings_df)

    assert actual_df.collect() == expected_df.collect()
