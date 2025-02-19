%{ for key, value in items ~}
%{ normalised = try(tostring(value), jsonencode(value))}
%{ if startswith(normalised, "[") || startswith(normalised, "{") ~}
${key} = ${normalised}
%{ else ~}
${key} = "${normalised}"
%{ endif ~}
%{ endfor ~}