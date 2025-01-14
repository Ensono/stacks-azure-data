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
    azapi = {
      source  = "Azure/azapi"
      version = "2.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
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

#provider "azapi" {
#}
