output "key_vault_id" {
  value = azurerm_key_vault.key_vault.id
}

output "key_name" {
  value = azurerm_key_vault_key.key.name
}

output "key_version" {
  value = azurerm_key_vault_key.key.version
}

output "key_vault_uri" {
    value = azurerm_key_vault.key_vault.vault_uri
}
