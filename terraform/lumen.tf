# Lumen infrastructure resources - imported into IaC management

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------

import {
  to = azurerm_resource_group.geni-lumen-test-app
  id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/geni-lumen-test-app"
}

resource "azurerm_resource_group" "geni-lumen-test-app" {
  name     = "geni-lumen-test-app"
  location = "northeurope"
}

# ---------------------------------------------------------------------------
# Log Analytics Workspace
# ---------------------------------------------------------------------------

import {
  to = azurerm_log_analytics_workspace.lumen-logs
  id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/geni-lumen-test-app/providers/Microsoft.OperationalInsights/workspaces/lumen-logs"
}

resource "azurerm_log_analytics_workspace" "lumen-logs" {
  name                = "lumen-logs"
  location            = azurerm_resource_group.geni-lumen-test-app.location
  resource_group_name = azurerm_resource_group.geni-lumen-test-app.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    app         = "lumen"
    environment = "shared"
    layer       = "substrate"
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Key Vault
# ---------------------------------------------------------------------------

import {
  to = azurerm_key_vault.lumenkv
  id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/geni-lumen-test-app/providers/Microsoft.KeyVault/vaults/lumenkv"
}

resource "azurerm_key_vault" "lumenkv" {
  name                            = "lumenkv"
  location                        = azurerm_resource_group.geni-lumen-test-app.location
  resource_group_name             = azurerm_resource_group.geni-lumen-test-app.name
  tenant_id                       = "597bfa71-7575-4506-93d7-dc147bddfb22"
  sku_name                        = "standard"
  soft_delete_retention_days      = 7
  purge_protection_enabled        = true
  enable_rbac_authorization       = true
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false

  tags = {
    app         = "lumen"
    environment = "shared"
    layer       = "substrate"
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Container Registry
# ---------------------------------------------------------------------------

import {
  to = azurerm_container_registry.lumenb29dffacr
  id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/geni-lumen-test-app/providers/Microsoft.ContainerRegistry/registries/lumenb29dffacr"
}

resource "azurerm_container_registry" "lumenb29dffacr" {
  name                = "lumenb29dffacr"
  resource_group_name = azurerm_resource_group.geni-lumen-test-app.name
  location            = azurerm_resource_group.geni-lumen-test-app.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    app         = "lumen"
    environment = "shared"
    layer       = "substrate"
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Public IP (AKS egress)
# ---------------------------------------------------------------------------

import {
  to = azurerm_public_ip.lumen-aks-egress-ip
  id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/geni-lumen-test-app/providers/Microsoft.Network/publicIPAddresses/lumen-aks-egress-ip"
}

resource "azurerm_public_ip" "lumen-aks-egress-ip" {
  name                    = "lumen-aks-egress-ip"
  resource_group_name     = azurerm_resource_group.geni-lumen-test-app.name
  location                = azurerm_resource_group.geni-lumen-test-app.location
  allocation_method       = "Static"
  sku                     = "Standard"
  ip_version              = "IPv4"
  idle_timeout_in_minutes = 4

  tags = {
    app         = "lumen"
    environment = "shared"
    layer       = "substrate"
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------------------------
# AKS Cluster
# ---------------------------------------------------------------------------

import {
  to = azurerm_kubernetes_cluster.lumen-aks
  id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/geni-lumen-test-app/providers/Microsoft.ContainerService/managedClusters/lumen-aks"
}

resource "azurerm_kubernetes_cluster" "lumen-aks" {
  name                = "lumen-aks"
  location            = azurerm_resource_group.geni-lumen-test-app.location
  resource_group_name = azurerm_resource_group.geni-lumen-test-app.name
  dns_prefix          = "lumen-aks"
  kubernetes_version  = "1.34"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name            = "system"
    node_count      = 2
    vm_size         = "Standard_B2s"
    max_pods        = 30
    os_disk_size_gb = 128
    os_sku          = "Ubuntu"
    type            = "VirtualMachineScaleSets"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"

    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.lumen-aks-egress-ip.id]
    }
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.lumen-logs.id
    msi_auth_for_monitoring_enabled = false
  }

  microsoft_defender {
    log_analytics_workspace_id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0-NEU"
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      windows_profile,
    ]
  }

  tags = {
    app         = "lumen"
    environment = "shared"
    layer       = "substrate"
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------------------------
# PostgreSQL Flexible Server
# ---------------------------------------------------------------------------

import {
  to = azurerm_postgresql_flexible_server.lumen-staging-postgres
  id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/geni-lumen-test-app/providers/Microsoft.DBforPostgreSQL/flexibleServers/lumen-staging-postgres"
}

resource "azurerm_postgresql_flexible_server" "lumen-staging-postgres" {
  name                   = "lumen-staging-postgres"
  resource_group_name    = azurerm_resource_group.geni-lumen-test-app.name
  location               = azurerm_resource_group.geni-lumen-test-app.location
  # azurerm 3.50.0 validates version against [11, 12, 13, 14]; actual server is 16.
  # lifecycle ignore_changes prevents Terraform from proposing a version change after import.
  version                = "14"
  administrator_login    = "appadmin"
  administrator_password = var.lumen_postgres_admin_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  backup_retention_days  = 7
  zone                   = "1"

  lifecycle {
    ignore_changes = [
      administrator_password,
      version,
      zone,
    ]
  }

  tags = {
    app         = "lumen"
    environment = "staging"
    layer       = "app-overlay"
    managed_by  = "terraform"
    source_pr   = "31"
  }
}

# ---------------------------------------------------------------------------
# Storage Account (Terraform state backend for lumen)
# ---------------------------------------------------------------------------

import {
  to = azurerm_storage_account.lumentfstateb29dff
  id = "/subscriptions/b29dff3d-6e8d-4bb9-a8c0-b2d9fef4fef0/resourceGroups/geni-lumen-test-app/providers/Microsoft.Storage/storageAccounts/lumentfstateb29dff"
}

resource "azurerm_storage_account" "lumentfstateb29dff" {
  name                     = "lumentfstateb29dff"
  resource_group_name      = azurerm_resource_group.geni-lumen-test-app.name
  location                 = azurerm_resource_group.geni-lumen-test-app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"

  enable_https_traffic_only        = true
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }

  tags = {
    app        = "lumen"
    layer      = "tfstate"
    managed_by = "geni"
  }
}
