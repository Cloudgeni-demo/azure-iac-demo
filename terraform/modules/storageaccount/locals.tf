locals {
  storage_account_principal_id = var.customer_managed_key_enabled ? azurerm_storage_account.storage_account.identity[0].principal_id : null
}
