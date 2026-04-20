variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "resource_group" {
  description = "The name of the resource group"
  type        = string
}

variable "region" {
  description = "The Azure region where the Key Vault will be created"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault (standard or premium)"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "The name of the Key Vault Key"
  type        = string
}

variable "key_type" {
  description = "The type of the Key Vault Key (RSA or EC)"
  type        = string
  default     = "RSA"
}

variable "key_size" {
  description = "The size of the Key Vault Key"
  type        = number
  default     = 2048
}

variable "tags" {
  description = "Tags to apply to the Key Vault"
  type        = map(any)
  default     = {}
}
