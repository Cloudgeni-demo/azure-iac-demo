terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rgp-mywplab"
    storage_account_name = "samywplab"
    container_name       = "tfstate"
    key                  = "azure-wordpress-ha.tfstate"
  }
}


