resource "databricks_workspace_conf" "this" {
  count = var.databricks_enableDbfsFileBrowser ? 1 : 0
  custom_config = {
    "enableDbfsFileBrowser" : "true"
  }
  depends_on = [module.adb]
}
