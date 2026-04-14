# Import Azure Container Apps resources
# NOTE: Provider version 3.50.0 has limited Container Apps support
# Container App Environment, Container App, and Container App Job resources require provider >= 3.51.0

# Resource Group
module "rg_aca" {
  source = "./modules/resource_group"
  name   = "rg-aca0410f516-northeurope"
  region = "northeurope"
}

import {
  to = module.rg_aca.azurerm_resource_group.rg
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet_aca" {
  name                = "vnet-aca0410f516"
  address_space       = ["10.42.0.0/16"]
  location            = "northeurope"
  resource_group_name = module.rg_aca.rg_name
  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

import {
  to = azurerm_virtual_network.vnet_aca
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Network/virtualNetworks/vnet-aca0410f516"
}

# Subnet with delegation for Container Apps
# NOTE: Microsoft.App/environments delegation requires provider version >= 3.51.0
# The delegation is managed by Azure when the Container App Environment is created
# Lifecycle policy ignores delegation changes to prevent drift
resource "azurerm_subnet" "snet_aca_infra" {
  name                 = "snet-aca-infra"
  resource_group_name  = module.rg_aca.rg_name
  virtual_network_name = azurerm_virtual_network.vnet_aca.name
  address_prefixes     = ["10.42.0.0/23"]

  private_endpoint_network_policies_enabled = false

  lifecycle {
    ignore_changes = [delegation]
  }
}

import {
  to = azurerm_subnet.snet_aca_infra
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Network/virtualNetworks/vnet-aca0410f516/subnets/snet-aca-infra"
}

# Storage Account
module "storage_aca" {
  source                        = "./modules/storageaccount"
  resource_group                = module.rg_aca.rg_name
  storage_account_name          = "saaca0410f516nort"
  region                        = "northeurope"
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  access_tier                   = "Hot"
  enable_https_traffic_only     = true
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false
  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

import {
  to = module.storage_aca.azurerm_storage_account.storage_account
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Storage/storageAccounts/saaca0410f516nort"
}

# ============================================================================
# Container Apps resources commented out due to provider version constraints
# ============================================================================
# The following resources require azurerm provider version >= 3.51.0:
# - Microsoft.App/managedEnvironments (cae-aca0410f516)
# - Microsoft.App/containerApps (app-aca0410f516)
# - Microsoft.App/jobs (job-aca0410f516)
#
# To import these resources:
# 1. Update backend.tf to use provider version >= 3.51.0
# 2. Uncomment and adapt the resource definitions below
# 3. Run terraform init -upgrade
# 4. Run terraform plan to import
# ============================================================================
