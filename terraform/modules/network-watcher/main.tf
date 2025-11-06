resource "azurerm_network_watcher" "network_watcher" {
  name                = "network-watcher-${var.region}"
  location            = var.region
  resource_group_name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                = "la-workspace-${var.name}"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "sa" {
  name                     = "sa${var.name}"
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_network_watcher_flow_log" "flow_log" {
  name                 = var.flow_log_name
  network_watcher_name = azurerm_network_watcher.network_watcher.name
  resource_group_name  = var.resource_group_name

  network_security_group_id = var.network_security_group_id
  storage_account_id        = azurerm_storage_account.sa.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.la_workspace.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.la_workspace.location
    workspace_resource_id = azurerm_log_analytics_workspace.la_workspace.id
    interval_in_minutes   = 10
  }
}
