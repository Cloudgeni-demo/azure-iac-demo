resource "azurerm_monitor_action_group" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  short_name          = var.short_name

  email_receiver {
    name          = "send-to-admin"
    email_address = "admin@contoso.com"
  }
}

