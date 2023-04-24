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
  azure_client_id            = env("AZURE_CLIENT_ID")
  azure_client_secret = env("AZURE_CLIENT_SECRET")
  azure_tenant_id     = env("AZURE_TENANT_ID")

}
