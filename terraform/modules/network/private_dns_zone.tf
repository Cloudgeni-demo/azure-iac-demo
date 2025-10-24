resource "azurerm_private_dns_zone" "blob_private_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_private_dns_zone_virtual_network_link" {
  name                  = "${var.name}-blob-pdnsz-vnet-link"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.blob_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "dfs_private_dns_zone" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs_private_dns_zone_virtual_network_link" {
  name                  = "${var.name}-dfs-pdnsz-vnet-link"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.dfs_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
