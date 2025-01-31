terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.4.0"
    }
  }

}

provider "azuredevops" {
  org_service_url = var.ado_org_url
}

provider "azurerm" {
  features {}
}

