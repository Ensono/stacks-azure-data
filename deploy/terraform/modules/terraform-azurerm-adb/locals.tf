locals {
  public_ip_name   = "${var.resource_namer}-pip"
  nat_gateway_name = "${var.resource_namer}-nat-gw"
  lb_name          = "${var.resource_namer}-lb"
}
