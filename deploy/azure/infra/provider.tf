terraform {
  backend "azurerm" {
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.117.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.59.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.15.0"
    }
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
