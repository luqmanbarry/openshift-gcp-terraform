terraform {
  required_providers {
    
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3"
    }

    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2"
    }

  }
}

provider "azurerm" {
  environment = var.azure_cloud_environment
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = false
    }
  }
  # Authentication credentials will be exposed as environment variables
  # export ARM_CLIENT_ID="xxxxxx"
  # export ARM_SUBSCRIPTION_ID="xxxxxx"
  # export ARM_TENANT_ID="xxxxxx"
  # export ARM_CLIENT_SECRET="xxxxxx"
}

provider "azuread" {
  # Authentication crdentials will be provided as env vars
  environment = var.azure_cloud_environment
}