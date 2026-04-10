# Import blocks for Azure Container Apps resources

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

# Import Container App Environment
import {
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/managedEnvironments/cae-aca0410f516"
  to = azurerm_container_app_environment.cae_aca_import
}

# Import Container App
import {
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/containerApps/app-aca0410f516"
  to = azurerm_container_app.app_aca_import
}

# Import Container App Job
import {
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/jobs/job-aca0410f516"
  to = azurerm_container_app_job.job_aca_import
}

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
  name                     = "saaca0410f516nort"
  resource_group_name      = azurerm_resource_group.rg_aca_import.name
  location                 = azurerm_resource_group.rg_aca_import.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
  enable_https_traffic_only       = true
  cross_tenant_replication_enabled = false

  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

# Container App Environment
resource "azurerm_container_app_environment" "cae_aca_import" {
  name                = "cae-aca0410f516"
  location            = azurerm_resource_group.rg_aca_import.location
  resource_group_name = azurerm_resource_group.rg_aca_import.name

  infrastructure_subnet_id       = azurerm_subnet.snet_aca_infra_import.id
  internal_load_balancer_enabled = false
  zone_redundancy_enabled        = false

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

# Container App
resource "azurerm_container_app" "app_aca_import" {
  name                         = "app-aca0410f516"
  container_app_environment_id = azurerm_container_app_environment.cae_aca_import.id
  resource_group_name          = azurerm_resource_group.rg_aca_import.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

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
    allow_insecure_connections = false

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

# Container App Job
resource "azurerm_container_app_job" "job_aca_import" {
  name                         = "job-aca0410f516"
  location                     = azurerm_resource_group.rg_aca_import.location
  resource_group_name          = azurerm_resource_group.rg_aca_import.name
  container_app_environment_id = azurerm_container_app_environment.cae_aca_import.id
  workload_profile_name        = "Consumption"
  replica_timeout_in_seconds   = 300
  replica_retry_limit          = 0

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
