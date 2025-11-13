resource "azurerm_lb_backend_address_pool" "debug" {
  count = var.enable_private_networks == true && var.debug_enabled == true ? 1 : 0

  name            = "VMSSBackendPool"
  loadbalancer_id = azurerm_lb.debug[0].id
}
