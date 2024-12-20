resource "azurerm_resource_group" "default" {
  name     = module.label_default.id
  location = var.resource_group_location
  tags     = module.label_default.tags
}
