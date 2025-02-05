locals {
  # Determine the expiration data of the secrets in the key vault
  secret_expiration_date = timeadd(timestamp(), var.kv_secret_expiration)
}
