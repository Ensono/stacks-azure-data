# Created by georgecalvert at 19/04/2023
Feature:Azure Data Ingest
  # Enter feature description here

  Scenario: Test Scenario
    Given the ADF pipeline Ingest_AzureSql_Example has been triggered
    And the ADF pipeline Ingest_AzureSql_Example has finished with state Succeeded