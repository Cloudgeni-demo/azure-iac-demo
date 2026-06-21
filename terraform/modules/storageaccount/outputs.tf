output "storage_account_identity" {
  description = "The identity of the storage account."
  value       = azurerm_storage_account.storage_account.identity
}

output "key_vault_id" {
  description = "The ID of the key vault."
  value       = var.customer_managed_key_enabled ? azurerm_key_vault.key_vault[0].id : null
}
