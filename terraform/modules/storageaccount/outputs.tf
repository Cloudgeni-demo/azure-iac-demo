output "storage_account_principal_id" {
  value = azurerm_storage_account.storage_account.identity[0].principal_id
}
