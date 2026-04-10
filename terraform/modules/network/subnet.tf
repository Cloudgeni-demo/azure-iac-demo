resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name != null ? var.subnet_name : "snt-${var.name}"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
  service_endpoints    = var.service_endpoints

  dynamic "delegation" {
    for_each = var.subnet_delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}