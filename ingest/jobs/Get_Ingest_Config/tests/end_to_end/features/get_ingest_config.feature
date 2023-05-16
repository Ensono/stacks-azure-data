Feature:Azure Data Ingest
  I want to ingest data
  so that it is available in Azure data lake storage

  Scenario Outline: Data Factory Ingest SQL Database into ADLS
    Given the ADF pipeline Get_Ingest_Config has been triggered with <parameters>
    And I poll the pipeline every 10 seconds until it has completed
    And the ADF pipeline Get_Ingest_Config has finished with state Succeeded
    And the ADF pipeline completed in less than 120 seconds
    Then the config files <output_files> are present in the ADLS container config in the directory ingest_sources

    Examples: Output files
    |parameters|output_files|
    |{"window_start" : "2020-01-01", "window_end": "2020-01-31"}|["example_azuresql_1.json", "schema/ingest_config_schema.json"]|