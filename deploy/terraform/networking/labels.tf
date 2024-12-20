# Naming convention
module "label_default" {
  source          = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace       = format("%s-%s", substr(var.name_company, 0, 16), substr(var.name_project, 0, 16))
  name            = "${lookup(local.location_name_map, var.resource_group_location)}-${substr(var.name_component, 0, 16)}"
  attributes      = var.attributes
  delimiter       = "-"
  id_length_limit = 60
  tags            = var.tags
}

# Naming convention
module "label_hub" {
  source          = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace       = format("%s-%s", substr(var.name_company, 0, 16), substr(var.name_project, 0, 16))
  stage           = "hub"
  name            = lookup(local.location_name_map, var.resource_group_location)
  attributes      = var.attributes
  delimiter       = "-"
  id_length_limit = 60
  tags            = var.tags
}
