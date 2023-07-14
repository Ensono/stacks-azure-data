Feature:Data Factory Get Ingest Config
  I want to get the ingest config
  so that I can ingest data

  Scenario Outline: Data Factory Ingest config
    Given the ADF pipeline Get_Ingest_Config has been triggered with <parameters>
    And I poll the pipeline every 10 seconds until it has completed
    And the ADF pipeline Get_Ingest_Config has finished with state Succeeded
    And the ADF pipeline completed in less than 120 seconds

    Examples: Get config
    |parameters|
    |{"config_container" : "config", "config_file": "Ingest_AzureSql_Example.json", "config_path": "ingest/Ingest_AzureSql_Example/ingest_sources"}|
