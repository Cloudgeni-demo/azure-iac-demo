data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  count                      = var.customer_managed_key_enabled ? 1 : 0
  name                       = var.key_vault_name
  location                   = var.region
  resource_group_name        = var.resource_group
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}



resource "azurerm_key_vault_key" "key" {
  count        = var.customer_managed_key_enabled ? 1 : 0
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.key_vault[0].id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "wrapKey",
  ]
}
