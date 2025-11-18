
variable "key_vault_name" {
  type        = string
  description = "The name of the key vault"
}

variable "location" {
  type        = string
  description = "The location of the key vault"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID"
}

variable "sku_name" {
  type        = string
  default     = "standard"
  description = "The SKU name of the key vault"
}

variable "enabled_for_disk_encryption" {
  type        = bool
  default     = true
  description = "Whether to enable disk encryption for the key vault"
}

variable "soft_delete_retention_days" {
  type        = number
  default     = 7
  description = "The number of days to retain soft-deleted secrets"
}

variable "purge_protection_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable purge protection for the key vault"
}

variable "key_name" {
  type        = string
  description = "The name of the key vault key"
}


