%{ for key, value in items ~}
${key} = "${replace(jsonencode(value), "\"", "\\\"")}"
%{ endfor ~}