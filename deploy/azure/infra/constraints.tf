terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    databricks = {
      source = "databricks/databricks"
    }

    azapi = {
      source = "Azure/azapi"
    }

  }
}
