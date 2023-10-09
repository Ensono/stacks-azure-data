Feature:Azure Data Ingest
  I want to ingest data
  so that it is available in Azure data lake storage

  Scenario Outline: Data Factory Ingest SQL Database into ADLS
    Given the ADF pipeline ingest_azure_sql_example has been triggered with <parameters>
    And I poll the pipeline every 10 seconds until it has completed
    Then the ADF pipeline ingest_azure_sql_example has finished with state Succeeded
    And the ADF pipeline ingest_azure_sql_example completed in less than 900 seconds
    And the files <output_files> are present in the ADLS container raw in the directory ingest_azure_sql_example

    Examples: Output files
    |parameters|output_files|
    |{"window_start" : "2010-01-01", "window_end": "2010-01-31"}|["movies.keywords", "movies.keywords_dq", "movies.links", "movies.movies_metadata", "movies.movies_metadata_dq", "movies.ratings_small"]|
