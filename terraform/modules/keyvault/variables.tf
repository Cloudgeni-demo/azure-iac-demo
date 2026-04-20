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
  description = "The SKU name of the key vault"
  default     = "standard"
}

variable "key_name" {
  type        = string
  description = "The name of the key"
}

variable "identity_name" {
  type        = string
  description = "The name of the user assigned identity"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources"
  default     = {}
}
