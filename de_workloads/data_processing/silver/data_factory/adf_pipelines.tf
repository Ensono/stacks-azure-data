resource "azurerm_data_factory_pipeline" "pipeline_silver" {
  count           = var.include_data_quality == false ? 1 : 0
  name            = "NEW_silver"
  data_factory_id = data.azurerm_data_factory.factory.id
  activities_json = file("${path.module}/pipelines/silver.json")
  description     = "Bronze to Silver data transformation."
  folder          = "Process"
}

resource "azurerm_data_factory_pipeline" "pipeline_silver_dq" {
  count           = var.include_data_quality == true ? 1 : 0
  name            = "NEW_silver_dq"
  data_factory_id = data.azurerm_data_factory.factory.id
  activities_json = file("${path.module}/pipelines/silver_dq.json")
  description     = "Bronze to Silver data transformation, with data quality checks."
  folder          = "Process"
}
