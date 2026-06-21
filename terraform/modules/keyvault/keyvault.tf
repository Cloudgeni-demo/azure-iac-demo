resource "azurerm_key_vault" "key_vault" {
  name                        = "kv-${var.name}"
  location                    = var.region
  resource_group_name         = var.resource_group
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  tags = var.tags
}

resource "azurerm_key_vault_key" "key" {
  name         = "storage-account-key"
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

data "azurerm_client_config" "current" {}
