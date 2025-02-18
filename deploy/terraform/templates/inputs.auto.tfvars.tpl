%{ for key, value in items ~}
${key} = ${startswith(value, "[") ? value :}"${value}"
%{ endfor ~}