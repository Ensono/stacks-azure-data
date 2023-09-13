resource "azurerm_data_factory_trigger_tumbling_window" "trigger_Ingest_QA_DLP_Dataset" {
  name            = "trigger_Ingest_QA_DLP_Dataset"
  data_factory_id = data.azurerm_data_factory.factory.id
  start_time      = "2010-01-01T00:00:00Z"
  end_time        = "2011-12-31T23:59:59Z"
  frequency       = "Month"
  interval        = 1
  delay           = "02:00:00"
  max_concurrency = 4
  activated       = false

  pipeline {
    name = "Ingest_QA_DLP_Dataset"
    parameters = {
      window_start = "@{formatDateTime(trigger().outputs.windowStartTime,'yyyy-MM-dd')}",
      window_end   = "@{formatDateTime(trigger().outputs.windowEndTime,'yyyy-MM-dd')}"
    }
  }

  depends_on = [
    azurerm_resource_group_template_deployment.pipeline_Ingest_QA_DLP_Dataset
  ]
}
