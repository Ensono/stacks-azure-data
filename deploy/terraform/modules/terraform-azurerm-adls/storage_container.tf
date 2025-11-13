resource "azurerm_storage_container" "storage_container_blob" {
  for_each              = { for i in toset(local.containers_blob) : i.name => i }
  name                  = each.key
  storage_account_id    = data.azurerm_storage_account.storage_id[each.value.account].id
  container_access_type = var.container_access_type

  depends_on = [azurerm_storage_account.storage_account_default, azurerm_role_assignment.storage_role_context] #, null_resource.sleep]
}

