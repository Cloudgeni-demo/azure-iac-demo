resource "azurerm_key_vault" "key_vault" {
  name                       = var.key_vault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  tags                       = var.tags
  enable_rbac_authorization = false

  purge_protection_enabled = true
  soft_delete_retention_days = 7

}

resource "azurerm_key_vault_key" "key" {
  name         = var.key_name
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault.key_vault
  ]
}

resource "azurerm_key_vault_access_policy" "storage_account_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.user_assigned_identity.tenant_id
  object_id    = var.user_assigned_identity.principal_id
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
  ]
}

data "azurerm_client_config" "current" {}
