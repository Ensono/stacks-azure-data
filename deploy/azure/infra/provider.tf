terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host                        = module.adb.databricks_hosturl != "" ? module.adb.databricks_hosturl : var.adb_databricks_hosturl
  azure_workspace_resource_id = module.adb.adb_databricks_id != "" ? module.adb.adb_databricks_id : var.adb_databricks_id
  auth_type                   = "azure-client-secret"

}

provider "azapi" {
}
