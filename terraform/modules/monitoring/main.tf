resource "azurerm_monitor_action_group" "main" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name
}

resource "azurerm_monitor_activity_log_alert" "nsg_delete_alert" {
  name                = "nsg-delete-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.subscription_id]
  description         = "Alert when a Network Security Group is deleted."

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/delete"
    level          = "Informational"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
