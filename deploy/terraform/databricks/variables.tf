variable "adb_databricks_hosturl" {
  type        = string
  description = "Host URL of the Azure Databricks workspace"
  default     = "https://missingdata.example.com"
}

variable "adb_databricks_id" {
  type        = string
  description = "ID of the Azure Databricks workspace"
  default     = ""
}

variable "databricks_secret_scope_kv" {
  type        = string
  default     = "key-vault-backed"
  description = "Name of the databricks secret scope for Key vault."
}

variable "key_vault_id" {
  type        = string
  description = "ID of the key vault for which the secret scope needs to be set"
  default     = ""
}

variable "key_vault_uri" {
  type        = string
  description = "URI of the Key Vault to target"
  default     = ""
}

variable "databricks_enableDbfsFileBrowser" {
  type        = bool
  description = "Whether to enable Dbfs File browser for the Azure Databricks workspace"
  default     = true
}

variable "databricks_pat_comment" {
  type        = string
  default     = "Terraform Provisioning"
  description = "Comment for databricks PAT"
}

variable "databricks-token" {
  type        = string
  default     = "databricks-token"
  description = "Name of the Key for databricks token, its not the actual value/password but the by the name its referred to."
}

variable "kv_secret_expiration" {
  type        = string
  description = "Specify the duration of secrets in the key vault"
  default     = "8765h"
}
