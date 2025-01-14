resource "azurerm_public_ip" "pip" {
  count               = var.enable_private_network && var.create_pip && var.managed_vnet == false ? 1 : 0
  name                = local.public_ip_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}
