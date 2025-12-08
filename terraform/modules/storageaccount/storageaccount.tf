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
    type = "SystemAssigned"
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

resource "azurerm_storage_container" "container" {
  name                  = var.containers[count.index].name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.containers[count.index].container_access_type

  count = length(var.containers) > 0 ? length(var.containers) : 0
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

data "azurerm_client_config" "current" {}

data "azurerm_storage_account" "storage_account_identity" {
  count               = var.enable_cmk_encryption ? 1 : 0
  name                = azurerm_storage_account.storage_account.name
  resource_group_name = azurerm_storage_account.storage_account.resource_group_name

  depends_on = [azurerm_storage_account.storage_account]
}

resource "azurerm_key_vault_access_policy" "storage_account" {
  count        = var.enable_cmk_encryption ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_storage_account.storage_account_identity[0].identity[0].principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]

  depends_on = [data.azurerm_storage_account.storage_account_identity]
}

resource "azurerm_storage_account_customer_managed_key" "cmk" {
  count              = var.enable_cmk_encryption ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account.id
  key_vault_id       = var.key_vault_id
  key_name           = var.key_vault_key_name

  depends_on = [
    azurerm_key_vault_access_policy.storage_account
  ]
}

