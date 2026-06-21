resource "azurerm_user_assigned_identity" "storage_identity" {
  location            = var.region
  name                = "${var.storage_account_name}-identity"
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
    identity_ids = [azurerm_user_assigned_identity.storage_identity.id]
  }
  customer_managed_key {
    key_vault_key_id          = var.customer_managed_key_vault_key_id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_identity.id
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

resource "azurerm_key_vault_access_policy" "storage_account_access" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.storage_identity.principal_id

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

