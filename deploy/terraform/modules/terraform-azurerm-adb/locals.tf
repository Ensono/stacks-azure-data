locals {
  # Determine names of the resources from the IDs that have been provided
  nat_gateway_id_parts = split("/", var.nat_gateway_id)
  nat_gateway_name     = element(local.nat_gateway_id_parts, length(local.nat_gateway_id_parts) - 1)

  public_ip_id_parts = split("/", var.nat_gateway_pip_id)
  public_ip_name     = element(local.public_ip_id_parts, length(local.public_ip_id_parts) - 1)

}
