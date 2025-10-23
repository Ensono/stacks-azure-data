<#

.SYNOPSIS
Generates the documentation from the Terraform templates

#>

# Set the template that needs to be used to inject the output
$template = "// BEGIN_TF_DOCS\n{{ .Content }}\n// END_TF_DOCS"
$indent = 5

# Build up the list of generated documents that are required
terraform-docs adoc --show inputs --output-file /app/docs/workloads/azure/data/getting_started/workstation/networking.adoc --output-template $template --indent $indent .