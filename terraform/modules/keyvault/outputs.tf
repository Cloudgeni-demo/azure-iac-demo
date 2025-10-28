output "key_vault_id" {
  value = azurerm_key_vault.key_vault.id
}

output "key_vault_key_id" {
  value = azurerm_key_vault_key.key.id
}

output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.storage_identity.id
}

output "user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.storage_identity.principal_id
}
