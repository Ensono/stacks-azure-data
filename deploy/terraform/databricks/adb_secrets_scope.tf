resource "databricks_secret_scope" "kv" {
  name = var.databricks_secret_scope_kv

  keyvault_metadata {
    resource_id = replace(var.key_vault_id, "\"", "")
    dns_name    = replace(var.key_vault_uri, "\"", "")
  }

}
