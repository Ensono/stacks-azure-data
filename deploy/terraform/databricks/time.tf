# Define a time resource which will be used to set the expiration date of secrets
# in the key vault. By doing this the time is set in the state and the secrets
# will not be updated on each Terraform run
resource "time_static" "datum" {}
