resource "azurerm_monitor_action_group" "action_group" {
  name                = "nsg-delete-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "nsgdelete"
}

resource "azurerm_monitor_activity_log_alert" "delete_nsg_alert" {
  name                = "delete-nsg-alert"
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Alert when a Network Security Group is deleted."

  criteria {
    operation_name = "Microsoft.Network/networkSecurityGroups/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}
