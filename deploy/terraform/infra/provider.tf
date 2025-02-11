terraform {
  backend "azurerm" {
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


provider "azuredevops" {
  org_service_url = var.ado_org_url
}
