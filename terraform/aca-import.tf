# Import Azure Container Apps resources

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
resource "azurerm_subnet" "snet_aca_infra" {
  name                 = "snet-aca-infra"
  resource_group_name  = module.rg_aca.rg_name
  virtual_network_name = azurerm_virtual_network.vnet_aca.name
  address_prefixes     = ["10.42.0.0/23"]

  delegation {
    name = "0"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  private_endpoint_network_policies = "Disabled"
}

import {
  to = azurerm_subnet.snet_aca_infra
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Network/virtualNetworks/vnet-aca0410f516/subnets/snet-aca-infra"
}

# Storage Account
module "storage_aca" {
  source                    = "./modules/storageaccount"
  resource_group            = module.rg_aca.rg_name
  storage_account_name      = "saaca0410f516nort"
  region                    = "northeurope"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  access_tier               = "Hot"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
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

# Container Apps Managed Environment
resource "azurerm_container_app_environment" "cae_aca" {
  name                       = "cae-aca0410f516"
  location                   = "northeurope"
  resource_group_name        = module.rg_aca.rg_name
  infrastructure_subnet_id   = azurerm_subnet.snet_aca_infra.id
  internal_load_balancer_enabled = false
  zone_redundant_enabled     = false

  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

import {
  to = azurerm_container_app_environment.cae_aca
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/managedEnvironments/cae-aca0410f516"
}

# Container App
resource "azurerm_container_app" "app_aca" {
  name                         = "app-aca0410f516"
  container_app_environment_id = azurerm_container_app_environment.cae_aca.id
  resource_group_name          = module.rg_aca.rg_name
  revision_mode                = "Single"

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "app-aca0410f516"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

import {
  to = azurerm_container_app.app_aca
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/containerApps/app-aca0410f516"
}

# Container App Job
resource "azurerm_container_app_job" "job_aca" {
  name                         = "job-aca0410f516"
  location                     = "northeurope"
  resource_group_name          = module.rg_aca.rg_name
  container_app_environment_id = azurerm_container_app_environment.cae_aca.id

  replica_timeout_in_seconds = 300
  replica_retry_limit        = 0

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  template {
    container {
      name   = "job-aca0410f516"
      image  = "mcr.microsoft.com/k8se/quickstart-jobs:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

import {
  to = azurerm_container_app_job.job_aca
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/jobs/job-aca0410f516"
}
