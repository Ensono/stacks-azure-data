resource "azurerm_data_factory_pipeline" "pipeline_Ingest_AzureSql_Example" {
  count           = var.include_data_quality == false ? 1 : 0
  name            = "Ingest_AzureSql_Example"
  data_factory_id = var.data_factory_id
  activities_json = file("${path.module}/pipelines/Ingest_AzureSql_Example.json")
  description     = "Ingest from demo Azure SQL database using ingest config file."
  folder          = "Ingest"
  parameters = {
    data_source_name = "example_azuresql_1",
    window_start     = "2020-01-01",
    window_start     = "2020-01-31",
    correlation_id   = ""
  }
  depends_on = [
    azurerm_data_factory_custom_dataset.ds_ex_AzureSql_ExampleSource
  ]
}

resource "azurerm_data_factory_pipeline" "pipeline_Ingest_AzureSql_Example_DQ" {
  count           = var.include_data_quality == true ? 1 : 0
  name            = "Ingest_AzureSql_Example_DQ"
  data_factory_id = var.data_factory_id
  activities_json = file("${path.module}/pipelines/Ingest_AzureSql_Example_DQ.json")
  description     = "Ingest from demo Azure SQL database using ingest config file, with data quality checks."
  folder          = "Ingest"
  parameters = {
    data_source_name = "example_azuresql_1",
    window_start     = "2020-01-01",
    window_start     = "2020-01-31",
    correlation_id   = ""
  }
  depends_on = [
    azurerm_data_factory_custom_dataset.ds_ex_AzureSql_ExampleSource
  ]
}
