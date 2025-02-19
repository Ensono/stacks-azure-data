%{ for key, value in items ~}
${key} = ${tostring(value)}
%{ endfor ~}