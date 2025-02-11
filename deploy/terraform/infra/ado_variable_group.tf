# This resource runs once all the resources have been deployed
#
# It takes all of the outputs and puts them into the named resource group 
# in Azure DevOps

# NOTE: If the variable group is updated manually and this resource is run again
# the manual items will be lost

resource "azuredevops_variable_group" "ado_vg" {

  count = var.ado_create_variable_group ? 1 : 0

  project_id   = data.azuredevops_project.ado[0].id
  name         = local.ado_vg_name_prefix
  description  = "Azure resource names from the Infra deployment for the ${var.environment} environment. Do not update this group manually as it is managed by Terraform"
  allow_access = true

  # Use the dynamic block to create the variables from the local.outputs
  dynamic "variable" {
    for_each = [for out in local.outputs[var.environment] : out]
    content {
      name  = variable.key
      value = variable.value
    }
  }

  depends_on = [module.adf, module.adls_default, module.adf, module.sql]
}
