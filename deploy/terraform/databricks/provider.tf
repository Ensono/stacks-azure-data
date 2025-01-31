terraform {
  backend "azurerm" {
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.62.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host                        = var.adb_databricks_hosturl
  azure_workspace_resource_id = var.adb_databricks_id

}

