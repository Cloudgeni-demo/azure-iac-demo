output "postgresql_server_name" {
  value = azurerm_postgresql_flexible_server.postgresql_flexible_server.name
}

output "postgresql_server_fqdn" {
  value = azurerm_postgresql_flexible_server.postgresql_flexible_server.fqdn
}

output "postgresql_database_name" {
  value = azurerm_postgresql_flexible_server_database.postgresql_database.name
}

output "postgresql_server_id" {
  value = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
}
