%{ for key, value in items ~}
${key} = jsonencode(value)
%{ endfor ~}