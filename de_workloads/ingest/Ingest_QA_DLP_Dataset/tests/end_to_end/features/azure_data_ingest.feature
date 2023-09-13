Feature:Azure Data Ingest
  I want to ingest data
  so that it is available in Azure data lake storage

Scenario Outline: Data Factory Ingest SQL Database into ADLS with Data Quality
    Given the ADF pipeline Ingest_QA_DLP_Dataset has been triggered with <parameters>
    And I poll the pipeline every 10 seconds until it has completed
    And the ADF pipeline Ingest_QA_DLP_Dataset has finished with state Succeeded
    And the ADF pipeline completed in less than 900 seconds
    Then the files <output_files> are present in the ADLS container raw in the directory Ingest_QA_DLP_Dataset

    Examples: Output files
    |parameters|output_files|
    |{"window_start" : "2010-01-01", "window_end": "2010-01-31"}|["SalesLT.Customer", "SalesLT.Product", "SalesLT.ProductModel", "movies.ratings_small"]|
