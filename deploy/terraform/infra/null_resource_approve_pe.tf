# resource "null_resource" "approve_private_endpoints_old" {
#   for_each = local.private_endpoint_list

#   triggers = {
#     always_run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = <<-EOT
#         az login --service-principal -u ${trimspace(data.azurerm_client_config.current.client_id)} -p ${var.azure_client_secret} --tenant ${data.azurerm_client_config.current.tenant_id}
#         text=$(az network private-endpoint-connection list --id ${each.value})
#         pendingPE=`echo $text | jq -r '.[] | select(.properties.privateLinkServiceConnectionState.status == "Pending") | .id'`
#         for id in $pendingPE
#         do
#             echo "$id is in a pending state"
#             az network private-endpoint-connection approve --id "$id" --description "Approved"
#         done
#     EOT
#   }

#   depends_on = [azurerm_data_factory_managed_private_endpoint.db_auth_pe, azurerm_data_factory_managed_private_endpoint.db_pe, azurerm_data_factory_managed_private_endpoint.sql_pe, azurerm_data_factory_managed_private_endpoint.kv_pe, azurerm_data_factory_managed_private_endpoint.adls_pe, azurerm_data_factory_managed_private_endpoint.blob_pe]
# }

resource "null_resource" "approve_private_endpoints" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = "${path.module}/scripts/Approve-Endpoints.ps1 -ClientId ${data.azurerm_client_config.current.client_id} -TenantId ${data.azurerm_client_config.current.tenant_id} -EndpointIds '${jsonencode(local.private_endpoint_list)}'"
    environment = {
      ARM_CLIENT_SECRET = var.azure_client_secret
    }
  }
}
