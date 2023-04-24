terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host                        = module.adb.databricks_hosturl
  azure_workspace_resource_id = module.adb.adb_databricks_id
  azure_client_id = "${var.ARM_CLIENT_ID}"
  azure_client_secret = "${var.ARM_CLIENT_SECRET}"
  azure_tenant_id = "${var.ARM_TENANT_ID}"

}
