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

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }

    corefunc = {
      source  = "northwood-labs/corefunc"
      version = "~> 1.0"
    }

  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host                        = provider::corefunc::url_parse(replace(var.adb_databricks_hosturl, "\"", "")).host
  azure_workspace_resource_id = replace(var.adb_databricks_id, "\"", "")

}

