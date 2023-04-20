terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host = module.adb.databricks_hosturl

}
