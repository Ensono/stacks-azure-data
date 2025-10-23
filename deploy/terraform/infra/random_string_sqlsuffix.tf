# Create a random string as a suffix to the end of the SQL name
# this is to help when destorying and redeploying instances
resource "random_string" "random_suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}
