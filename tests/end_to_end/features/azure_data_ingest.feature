Feature:Azure Data Ingest
  I want to ingest data
  so that it is available in Azure data lake storage

  Scenario Outline: Test Scenario
    Given the ADF pipeline Ingest_AzureSql_Example has been triggered
    And the ADF pipeline Ingest_AzureSql_Example has finished with state Succeeded
    Then the parquet files <output_files> are present in the ADLS container raw in the directory example_azuresql_1

    Examples: Output files
    |output_files|
    |["SalesLT.Product", "SalesLT.SalesOrderDetailID", "SalesLT.SalesOrderHeader"]|