resource "azurerm_private_dns_zone" "dns_zone_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.resource_group.rg_name
}

resource "azurerm_private_dns_zone" "dns_zone_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = module.resource_group.rg_name
}

resource "azurerm_private_dns_zone" "dns_zone_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = module.resource_group.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link_blob" {
  name                  = "${local.suffix}-dns-link-blob"
  resource_group_name   = module.resource_group.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_blob.name
  virtual_network_id    = module.network.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link_file" {
  name                  = "${local.suffix}-dns-link-file"
  resource_group_name   = module.resource_group.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_file.name
  virtual_network_id    = module.network.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link_dfs" {
  name                  = "${local.suffix}-dns-link-dfs"
  resource_group_name   = module.resource_group.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_dfs.name
  virtual_network_id    = module.network.vnet_id
}
