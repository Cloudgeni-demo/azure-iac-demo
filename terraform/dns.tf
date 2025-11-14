resource "azurerm_private_dns_zone" "dns_zone_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.resource_group.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_blob" {
  name                  = "${local.suffix}-blob-dns-link"
  resource_group_name   = module.resource_group.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_blob.name
  virtual_network_id    = module.network.vnet_id
}
