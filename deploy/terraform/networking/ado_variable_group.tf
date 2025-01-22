# This resource runs once all the resources have been deployed
#
# It takes all of the outputs and puts them into the named resource group 
# in Azure DevOps

# NOTE: If the variable group is updated manually and this resource is run again
# the manual items will be lost

resource "azuredevops_variable_group" "ado_vg" {

  for_each = var.ado_create_variable_group ? {
    for name, detail in local.environments : name => detail if name != "hub"
  } : {}

  project_id   = data.azuredevops_project.ado[0].id
  name         = "${var.ado_variable_group_name_prefix}-${each.key}"
  description  = "Azure resource names from the Network deployment for the ${each.key} environment. Do not update this group manually as it is managed by Terraform"
  allow_access = true

  # Use the dynamic block to create the variables from the local.outputs
  dynamic "variable" {
    for_each = [for out in local.outputs[each.key] : out]
    content {
      name  = variable.key
      value = variable.value
    }
  }

  depends_on = [module.networking[0]]
}
