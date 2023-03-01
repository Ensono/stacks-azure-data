# # Naming convention
# module "default_label" {
#   source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
#   namespace  = format("%s-%s", var.name_company, var.name_project)
#   stage      = var.stage
#   name       = "${lookup(var.location_name_map, var.resource_group_location, "northeurope")}-${var.name_component}"
#   attributes = var.attributes
#   delimiter  = "-"
#   tags       = var.tags
# }

# module "data" {
#   source = "git::https://github.com/amido/stacks-terraform//azurerm/modules/azurerm-data-platform?ref=vXXXXXX"
# }
