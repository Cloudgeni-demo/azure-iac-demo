resource "azurerm_key_vault" "key_vault" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku_name
  enable_rbac_authorization = true

  tags = var.tags
}

resource "azurerm_key_vault_key" "key" {
  name         = var.key_name
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "wrapKey",
  ]

  depends_on = [
    azurerm_key_vault.key_vault,
    azurerm_role_assignment.storage_identity_role
  ]
}

resource "azurerm_user_assigned_identity" "storage_identity" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "storage_identity_role" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
}
