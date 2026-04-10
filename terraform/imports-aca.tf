# Import blocks for Azure Container Apps resources
# Note: Provider v3.50.0 has limited Container Apps support - some resources cannot be imported

# Import Resource Group
import {
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope"
  to = azurerm_resource_group.rg_aca_import
}

# Import Virtual Network
import {
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Network/virtualNetworks/vnet-aca0410f516"
  to = azurerm_virtual_network.vnet_aca_import
}

# Import Subnet
import {
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Network/virtualNetworks/vnet-aca0410f516/subnets/snet-aca-infra"
  to = azurerm_subnet.snet_aca_infra_import
}

# Import Storage Account
import {
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Storage/storageAccounts/saaca0410f516nort"
  to = azurerm_storage_account.sa_aca_import
}

# Container App Environment and Container Apps not imported due to provider version limitations
# Provider v3.50.0 does not support:
# - azurerm_container_app_environment (requires log_analytics_workspace_id and missing newer properties)
# - azurerm_container_app_job (resource type not available)
# These resources remain unmanaged. Upgrade to provider v3.71+ to import them.

# Resource Group
resource "azurerm_resource_group" "rg_aca_import" {
  name     = "rg-aca0410f516-northeurope"
  location = "northeurope"

  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "vnet_aca_import" {
  name                = "vnet-aca0410f516"
  location            = azurerm_resource_group.rg_aca_import.location
  resource_group_name = azurerm_resource_group.rg_aca_import.name
  address_space       = ["10.42.0.0/16"]

  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

# Subnet with delegation for Container Apps
# Note: Delegation is managed by the cloud - not explicitly defined to avoid provider validation issues
resource "azurerm_subnet" "snet_aca_infra_import" {
  name                 = "snet-aca-infra"
  resource_group_name  = azurerm_resource_group.rg_aca_import.name
  virtual_network_name = azurerm_virtual_network.vnet_aca_import.name
  address_prefixes     = ["10.42.0.0/23"]

  # Delegation to Microsoft.App/environments exists in cloud but is omitted here
  # to avoid Terraform provider validation errors with this newer service type
  lifecycle {
    ignore_changes = [delegation]
  }
}

# Storage Account
resource "azurerm_storage_account" "sa_aca_import" {
  name                             = "saaca0410f516nort"
  resource_group_name              = azurerm_resource_group.rg_aca_import.name
  location                         = azurerm_resource_group.rg_aca_import.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  account_kind                     = "StorageV2"
  access_tier                      = "Hot"
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  enable_https_traffic_only        = true
  cross_tenant_replication_enabled = false

  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}
