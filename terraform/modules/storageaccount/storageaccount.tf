resource "azurerm_user_assigned_identity" "storage_identity" {
  count               = var.customer_managed_key_enabled ? 1 : 0
  name                = "${var.storage_account_name}-identity"
  location            = var.region
  resource_group_name = var.resource_group
}

resource "azurerm_storage_account" "storage_account" {
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group
  location                  = var.region
  account_tier              = var.account_tier
  account_kind              = var.account_kind
  access_tier               = var.access_tier
  account_replication_type  = var.account_replication_type
  is_hns_enabled            = var.is_hns_enabled
  enable_https_traffic_only = var.enable_https_traffic_only
  public_network_access_enabled   = var.public_network_access_enabled 
  nfsv3_enabled             = var.nfsv3_enabled
  min_tls_version           = var.min_tls_version
  tags                      = var.tags
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_identity[0].id]
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_enabled ? [1] : []
    content {
      key_vault_key_id          = azurerm_key_vault_key.key[0].id
      user_assigned_identity_id = azurerm_user_assigned_identity.storage_identity[0].id
    }
  }

  dynamic "network_rules" {
    #check if network_rules has any rule to set below block
    for_each = var.network_rules
    iterator = item
    content {
      default_action             = item.value.default_action
      ip_rules                   = item.value.ip_rules
      virtual_network_subnet_ids = item.value.virtual_network_subnet_ids
    }
  }

  dynamic "blob_properties" {
    for_each =  var.account_kind != "FileStorage" && var.blob_properties != {} ? [1] : []
    content {
      dynamic "delete_retention_policy" {
        for_each = lookup(var.blob_properties, "delete_retention_policy_days", []) != [] ? [1] : []
        content {
          days = var.blob_properties.delete_retention_policy_days
        }
      }

      versioning_enabled = lookup(var.blob_properties, "versioning_enabled", false)
      dynamic "container_delete_retention_policy" {
        for_each = lookup(var.blob_properties, "container_delete_retention_policy_days", []) != [] ? [1] : []
        content {
          days = var.blob_properties.container_delete_retention_policy_days

        }
      }

    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  count                       = var.customer_managed_key_enabled ? 1 : 0
  name                        = var.key_vault_name
  location                    = var.region
  resource_group_name         = var.resource_group
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Create",
      "Get",
      "List",
      "Restore",
      "Recover",
      "Backup",
      "Purge",
      "Delete"
    ]
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Backup",
      "Restore",
      "Recover",
      "Purge"
    ]
  }
}

resource "azurerm_key_vault_key" "key" {
  count        = var.customer_managed_key_enabled ? 1 : 0
  name         = "${var.storage_account_name}-key"
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

resource "azurerm_key_vault_access_policy" "storage_account_policy" {
  count        = var.customer_managed_key_enabled ? 1 : 0
  key_vault_id = azurerm_key_vault.key_vault[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.storage_identity[0].principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_storage_container" "container" {
  name                  = var.containers[count.index].name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.containers[count.index].container_access_type

  count = length(var.containers) > 0 ? length(var.containers) : 0
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

