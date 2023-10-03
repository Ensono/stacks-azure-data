Feature:Data Factory Shared Resources
  I want to get config and generate queries in Data Factory
  so that I can ingest the correct data

  Scenario Outline: Data Factory get ingest config
    Given the ADF pipeline Get_Ingest_Config has been triggered with <parameters>
    And I poll the pipeline every 10 seconds until it has completed
    Then the ADF pipeline Get_Ingest_Config has finished with state Succeeded
    And the ADF pipeline Get_Ingest_Config completed in less than 120 seconds

    Examples: Get config
    |parameters|
    |{"config_container" : "config", "config_file": "test_config.json", "config_path": "automated_test/shared_steps_test"}|

  Scenario Outline: Data Factory generate ingest query
    Given the ADF pipeline Generate_Ingest_Query has been triggered with <parameters>
    And I poll the pipeline every 10 seconds until it has completed
    Then the ADF pipeline Generate_Ingest_Query has finished with state Succeeded
    And the ADF pipeline Generate_Ingest_Query completed in less than 60 seconds

    Examples: Generate query
    |parameters|
    |{"ingest_entity_config" : {"version":1,"display_name":"movies.keywords","enabled":true,"schema":"movies","table":"keywords","columns":"[id],[keywords]","load_type":"full","delta_date_column":null,"delta_upsert_key":null}, "window_start": "2020-01-01", "window_end": "2020-12-31"}|
    |{"ingest_entity_config" : {"version":1,"display_name":"movies.ratings_small","enabled":true,"schema":"movies","table":"ratings_small","columns":"[userId],[movieId],[rating],[timestamp]","load_type":"delta","delta_date_column":"DATEADD(SECOND,[timestamp],'1970-01-01')","delta_upsert_key":"[userId],[movieId]"}, "window_start": "2020-01-01", "window_end": "2020-12-31"}|
