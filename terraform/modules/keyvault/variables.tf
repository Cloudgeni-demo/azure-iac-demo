variable "key_vault_name" {
  type        = string
  description = "The name of the key vault."
}

variable "location" {
  type        = string
  description = "The location of the key vault."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the key vault."
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID of the subscription."
}

variable "sku_name" {
  type        = string
  description = "The SKU name of the key vault."
  default     = "standard"
}

variable "key_name" {
  type        = string
  description = "The name of the key in the key vault."
}

variable "identity_name" {
  type        = string
  description = "The name of the user assigned identity."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the key vault."
  default     = {}
}
