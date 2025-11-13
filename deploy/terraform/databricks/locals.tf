locals {
  # Determine the expiration data of the secrets in the key vault
  secret_expiration_date = timeadd(time_static.datum.rfc3339, var.kv_secret_expiration)
}
