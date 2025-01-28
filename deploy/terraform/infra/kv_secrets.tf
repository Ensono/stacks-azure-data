resource "azurerm_key_vault_secret" "databricks_token" {
  name            = var.databricks-token
  value           = databricks_token.pat.token_value
  key_vault_id    = module.kv_default.id
  content_type    = "token"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.adb, module.kv_default]
}

resource "azurerm_key_vault_secret" "databricks-host" {
  name            = var.databricks-host
  value           = module.adb.databricks_hosturl
  key_vault_id    = module.kv_default.id
  content_type    = "host"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.adb, module.kv_default]
}

# Add secrets to KV. Please note this is just going to add secret names to KV. The actual value of that secret needs to be updated manually in Azure Key Vault. Existing secrets with the same name will not be overwritten.
resource "azurerm_key_vault_secret" "secrets" {
  for_each        = toset(var.kv_secrets)
  name            = each.key
  value           = ""
  key_vault_id    = module.kv_default.id
  content_type    = "password"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.kv_default]
}

resource "azurerm_key_vault_secret" "sql_password" {
  name            = var.sql_password
  value           = module.sql.sql_sa_password
  key_vault_id    = module.kv_default.id
  content_type    = "password"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.kv_default]
}

resource "azurerm_key_vault_secret" "sql_connect_string" {
  for_each        = toset(var.sql_db_names)
  name            = "connect-string-${each.key}"
  value           = "Server=tcp:${module.sql.sql_server_name}.database.windows.net,1433;Database=${each.key};User ID=${module.sql.sql_sa_login};Password=${module.sql.sql_sa_password};Trusted_Connection=False;Encrypt=True;Connection Timeout=30"
  key_vault_id    = module.kv_default.id
  content_type    = "connectionString"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.kv_default]
}

resource "azurerm_key_vault_secret" "sql_password_string" {
  for_each        = toset(var.sql_db_names)
  name            = "connect-sql-password-${each.key}"
  value           = module.sql.sql_sa_password
  key_vault_id    = module.kv_default.id
  content_type    = "password"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.kv_default]
}

resource "azurerm_key_vault_secret" "service-principal-secret" {
  name            = "service-principal-secret"
  value           = data.external.env.result["ARM_CLIENT_SECRET"]
  key_vault_id    = module.kv_default.id
  content_type    = "password"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.kv_default]
}

resource "azurerm_key_vault_secret" "azure-client-id" {
  name            = "azure-client-id"
  value           = data.azurerm_client_config.current.client_id
  key_vault_id    = module.kv_default.id
  content_type    = "spn"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.kv_default]
}

resource "azurerm_key_vault_secret" "azure-tenant-id" {
  name            = "azure-tenant-id"
  value           = data.azurerm_client_config.current.tenant_id
  key_vault_id    = module.kv_default.id
  content_type    = "spn"
  expiration_date = local.secret_expiration_date
  depends_on      = [module.kv_default]
}
