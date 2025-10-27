variable "key_vault_name" {
  type        = string
  description = "The name of the key vault"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The location of the key vault"
}

variable "sku_name" {
  type        = string
  description = "The SKU of the key vault"
  default     = "standard"
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the key vault"
  default     = {}
}
