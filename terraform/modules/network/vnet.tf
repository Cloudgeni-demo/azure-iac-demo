resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.name}"
  address_space       = var.vnet_address_space
  location            = var.region
  resource_group_name = var.resource_group
}
