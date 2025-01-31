%{ for key, value in items ~}
${key} = "${replace(value, "\"", "\\\"")}"
%{ endfor ~}