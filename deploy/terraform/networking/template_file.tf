
resource "local_file" "variable_output" {

  for_each = var.enable_private_networks ? { for item in local.templates : "${item.envname}-${item.file}" => item } : {}

  content  = templatefile(each.value.template, { items = each.value.items })
  filename = "${path.module}/${var.script_file_output_dir}/terraform/${each.value.envname}-networking-${trimsuffix(each.value.file, ".tpl")}"

}

# Create a null resource that will change the permissions of the files
# this is so that they can be easily updated in any demos and by the current user
resource "null_resource" "change_permissions" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "chmod 666 ${path.module}/${var.script_file_output_dir}/terraform/*.bash"
  }
}
