resource "azurerm_storage_account_customer_managed_key" "cmk" {
  count = var.customer_managed_key_enabled ? 1 : 0

  storage_account_id = azurerm_storage_account.storage_account.id
  key_vault_id       = azurerm_key_vault.key_vault[0].id
  key_name           = azurerm_key_vault_key.key[0].name
}
