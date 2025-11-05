
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                       = var.key_vault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku_name                   = var.sku_name
  tenant_id                  = var.tenant_id
  enable_rbac_authorization = true
  tags                       = var.tags
}

resource "azurerm_key_vault_key" "key" {
  name         = "${var.key_vault_name}-key"
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
