output "key_vault_id" {
  value = azurerm_key_vault.key_vault.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.key_vault.vault_uri
}

output "key_id" {
  value = azurerm_key_vault_key.key.id
}

output "key_version" {
    value = azurerm_key_vault_key.key.version
}

output "identity_id" {
  value = azurerm_user_assigned_identity.storage_identity.id
}

output "identity_principal_id" {
    value = azurerm_user_assigned_identity.storage_identity.principal_id
}
