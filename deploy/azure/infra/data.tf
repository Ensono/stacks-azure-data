data "azurerm_client_config" "current" {}

data "azurerm_subnet" "pe_subnet" {
  name                 = "backend"
  virtual_network_name = "production"
  resource_group_name  = "networking"
} #TODO

data "azurerm_private_dns_zone" "private_dns" {
  name                = "contoso.internal"
  resource_group_name = "contoso-dns"
} #TODO