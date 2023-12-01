from ...spark_jobs.process import transform_keywords, transform_movies_metadata


def test_transform_keywords(spark):
    data = [
        (862, "[{'id': 931, 'name': 'jealousy'}, {'id': 4290, 'name': 'toy'}, {'id': 5202, 'name': 'boy'}]"),
        (15602, "[{'id': 1495, 'name': 'fishing'}, {'id': 208510, 'name': 'old men'}]"),
    ]

    test_df = spark.createDataFrame(data, ["id", "keywords"])

    transformed_df = transform_keywords(test_df)

    assert transformed_df.columns == ["id", "keyword_id", "keyword_name"]
    assert transformed_df.count() == 5


def test_transform_movies_metadata(spark):
    data = [
        (
            "False",
            "{'id': 10194, 'name': 'Toy Story Collection', 'poster_path': '/7G9B.jpg', 'backdrop_path': '/9FBUq.jpg'}",
            "30000000",
            "[{'id': 16, 'name': 'Animation'}, {'id': 35, 'name': 'Comedy'}, {'id': 10751, 'name': 'Family'}]",
            "http://toystory.disney.com/toy-story",
            "862",
            "tt0114709",
            "en",
            "Toy Story",
            "Led by Woody, Andy's toys live happily in his room...",
            "21.946943",
            "/rhIRbceoE9lR4veEXuwCC2wARtG.jpg",
            "[{'name': 'Pixar Animation Studios', 'id': 3}]",
            "[{'iso_3166_1': 'US', 'name': 'United States of America'}]",
            "1995-10-30",
            373554033,
            81.0,
            "[{'iso_639_1': 'en', 'name': 'English'}]",
            "Released",
            "",
            "Toy Story",
            "False",
            "7.7",
            5415,
        )
    ]

    columns = [
        "adult",
        "belongs_to_collection",
        "budget",
        "genres",
        "homepage",
        "id",
        "imdb_id",
        "original_language",
        "original_title",
        "overview",
        "popularity",
        "poster_path",
        "production_companies",
        "production_countries",
        "release_date",
        "revenue",
        "runtime",
        "spoken_languages",
        "status",
        "tagline",
        "title",
        "video",
        "vote_average",
        "vote_count",
    ]

    test_df = spark.createDataFrame(data, columns)
    transformed_df = transform_movies_metadata(test_df)

    expected_cols = [
        "adult",
        "belongs_to_collection",
        "budget",
        "homepage",
        "id",
        "imdb_id",
        "original_language",
        "original_title",
        "overview",
        "popularity",
        "poster_path",
        "release_date",
        "revenue",
        "runtime",
        "status",
        "tagline",
        "title",
        "video",
        "vote_average",
        "vote_count",
        "genre_id",
        "genre_name",
        "production_company_name",
        "production_country_iso",
        "spoken_language_iso",
    ]

    assert transformed_df.columns == expected_cols
    assert transformed_df.count() == 3
