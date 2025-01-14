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

//This module should be used to generate names for resources that have limits:
//// Between 3 and 24 characters long.
//// Lowercase letters or numbers.
//// Storage Account names must be globally unique.
module "default_label_short" {
  source              = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace           = format("%s-%s", substr(var.name_company, 0, 4), substr(var.name_project, 0, 4))
  stage               = var.environment
  name                = "${lookup(local.location_name_map, var.resource_group_location)}-${substr(var.name_component, 0, 6)}"
  attributes          = concat([random_string.random_suffix.result], var.attributes)
  delimiter           = ""
  tags                = var.tags
  id_length_limit     = 20
  regex_replace_chars = "/[^a-zA-Z0-9]/"
}
