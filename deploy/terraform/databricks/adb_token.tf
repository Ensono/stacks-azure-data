resource "databricks_token" "pat" {
  comment = var.databricks_pat_comment
  // 120 day token
  lifetime_seconds = 120 * 24 * 60 * 60
}
