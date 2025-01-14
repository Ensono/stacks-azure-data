
resource "azurerm_lb" "lb" {
  count = var.enable_private_network && var.create_lb && var.managed_vnet == false ? 1 : 0

  name                = local.lb_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "Databricks-PIP"
    public_ip_address_id = azurerm_public_ip.pip[0].id
  }
}

resource "azurerm_lb_outbound_rule" "lb_rule" {
  count = var.enable_private_network && var.create_lb && var.managed_vnet == false ? 1 : 0

  name = "Databricks-LB-Outbound-Rules"

  loadbalancer_id          = azurerm_lb.lb[0].id
  protocol                 = "All"
  enable_tcp_reset         = true
  allocated_outbound_ports = 1024
  idle_timeout_in_minutes  = 4

  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_be_pool[0].id

  frontend_ip_configuration {
    name = azurerm_lb.lb[0].frontend_ip_configuration[0].name
  }
}

resource "azurerm_lb_backend_address_pool" "lb_be_pool" {
  count           = var.enable_private_network && var.create_lb && var.managed_vnet == false ? 1 : 0
  loadbalancer_id = azurerm_lb.lb[0].id
  name            = "Databricks-BE"
}
