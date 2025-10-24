resource "azurerm_role_assignment" "storage_role_context" {
  for_each             = var.storage_account_details
  scope                = azurerm_storage_account.storage_account_default[each.key].id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.azure_object_id

}

resource "time_sleep" "role_assignment_sleep" {
  for_each = var.storage_account_details

  create_duration = "60s"

  triggers = {
    role_assignment = azurerm_role_assignment.storage_role_context[each.key].id
  }
}
