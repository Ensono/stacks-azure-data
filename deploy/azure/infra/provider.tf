terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {

    # Enable the purging of secrets on delete
    # This is so that when a Key Vault is destroyed it can be recreated
    # without the keys and secrets coming back from a soft delete
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
  }
}

provider "databricks" {
  host                        = module.adb.databricks_hosturl
  azure_workspace_resource_id = module.adb.adb_databricks_id
  auth_type                   = "azure-client-secret"

}

provider "azapi" {
}
