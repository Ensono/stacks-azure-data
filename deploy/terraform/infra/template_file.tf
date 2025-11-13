
resource "local_file" "variable_output" {

  for_each = { for item in local.templates : "${item.envname}-${item.file}" => item }

  content  = templatefile(each.value.template, { items = each.value.items })
  filename = "${path.module}/${var.script_file_output_dir}/terraform/${each.value.envname}-infra-${trimsuffix(each.value.file, ".tpl")}"

}
