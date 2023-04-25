Feature:Azure Data Ingest
  I want to ingest data
  so that it is available in Azure data lake storage

  Scenario Outline: Data Factory Ingest SQL Database into ADLS
    Given the ADF pipeline Ingest_AzureSql_Example has been triggered with parameters <parameters>
    And I poll the pipeline every 10 seconds until it has completed
    And the ADF pipeline Ingest_AzureSql_Example has finished with state Succeeded
    And the ADF pipeline completed in less than 120 seconds
    Then the parquet files <output_files> are present in the ADLS container raw in the directory example_azuresql_1

    Examples: Output files
    |parameters|output_files|
    |{"window_start" : "2020-01-01", "window_end": "2020-01-31"}|["SalesLT.Product", "SalesLT.SalesOrderDetailID", "SalesLT.SalesOrderHeader"]|