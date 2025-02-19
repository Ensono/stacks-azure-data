%{ for key, value in items ~}
%{ if type(value) == "string" ~}
${key} = "${value}""
%{ else ~}
${key} = ${jsonencode(value)}
%{ endif ~}
%{ endfor ~}