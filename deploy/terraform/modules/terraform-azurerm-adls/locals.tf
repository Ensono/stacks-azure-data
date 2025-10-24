locals {
  containers_blob      = flatten([for account_name, account_details in var.storage_account_details : [for container_name in account_details.containers_name : { name = container_name, account = account_name }] if account_details.hns_enabled != true])
  containers_adls      = flatten([for account_name, account_details in var.storage_account_details : [for container_name in account_details.containers_name : { name = container_name, account = account_name }] if account_details.hns_enabled == true])
  adls_storage_account = flatten([for account_name, account_details in var.storage_account_details : account_name if account_details.hns_enabled == true])
  blob_storage_account = flatten([for account_name, account_details in var.storage_account_details : account_name if account_details.hns_enabled != true])

}
