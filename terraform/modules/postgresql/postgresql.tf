resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                         = var.resource_postgresql_name
  location                     = var.region
  resource_group_name          = var.resource_group
  sku_name                     = var.database_sku
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup
  administrator_login          = var.database_postgresql_admin_username
  administrator_password       = var.database_postgresql_admin_password
  version                      = var.database_postgresql_version
  delegated_subnet_id          = var.subnet_id != "" ? var.subnet_id : null
  private_dns_zone_id          = var.private_dns_zone_id != "" ? var.private_dns_zone_id : null
  tags                         = var.tags
  zone                         = var.postgresql_zone != "" ? var.postgresql_zone : null
  storage_mb                   = var.storage_mb

  dynamic "high_availability" {
    for_each = var.high_availability_enabled == true ? ["1"] : []
    content {
      mode = var.ha_mode
    }
  }

  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
  }
}

resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server_replica" {
  name                  = "${var.resource_postgresql_name}-replica"
  create_mode           = "Replica"
  location              = var.region
  resource_group_name   = var.resource_group
  sku_name              = var.replica_database_sku != "" ? var.replica_database_sku : var.database_sku
  backup_retention_days = var.backup_retention_days
  version               = var.database_postgresql_version
  delegated_subnet_id   = var.subnet_id != "" ? var.subnet_id : null
  private_dns_zone_id   = var.private_dns_zone_id != "" ? var.private_dns_zone_id : null
  source_server_id      = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  zone                  = var.postgresql_replica_zone
  tags                  = var.tags
  count                 = var.create_replica == true ? 1 : 0

  lifecycle {
    ignore_changes = [
      zone,
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "postgresql_database" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql_firewall_rule" {
  name             = var.vm_nsg_whitelist_ips_ports[count.index].name
  server_id        = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  start_ip_address = var.vm_nsg_whitelist_ips_ports[count.index].source_ip
  end_ip_address   = var.vm_nsg_whitelist_ips_ports[count.index].source_ip
  count            = length(var.vm_nsg_whitelist_ips_ports) > 0 ? length(var.vm_nsg_whitelist_ips_ports) : 0
  depends_on = [
    azurerm_postgresql_flexible_server.postgresql_flexible_server
  ]
}

resource "azurerm_postgresql_flexible_server_configuration" "server_parameters" {
  name      = var.server_parameters[count.index].name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  value     = var.server_parameters[count.index].value
  count     = length(var.server_parameters) > 0 ? length(var.server_parameters) : 0
}
