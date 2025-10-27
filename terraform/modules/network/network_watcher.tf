
resource "azurerm_network_watcher" "nw" {
  name                = "NetworkWatcher_${var.region}"
  location            = var.region
  resource_group_name = var.resource_group
}

resource "azurerm_network_watcher_flow_log" "flow_log" {
  name                      = "flowlog_${var.name}"
  network_watcher_name      = azurerm_network_watcher.nw.name
  resource_group_name       = var.resource_group
  network_security_group_id = azurerm_network_security_group.nsg[0].id
  storage_account_id        = var.storage_account_id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.log_analytics_workspace_location
    workspace_resource_id = var.log_analytics_workspace_resource_id
    interval_in_minutes   = 10
  }
}
