resource "databricks_secret_scope" "kv" {
  name = var.databricks_secret_scope_kv

  keyvault_metadata {
    resource_id = module.kv_default.id
    dns_name    = module.kv_default.vault_uri
  }
  depends_on = [module.adb, module.kv_default]
}
