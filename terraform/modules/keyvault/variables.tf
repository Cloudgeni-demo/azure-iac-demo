
variable "key_vault_name" {
  description = "The name of the key vault"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the key vault"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the key vault"
  type        = string
  default     = "standard"
}

variable "tenant_id" {
  description = "The tenant ID of the subscription"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the key vault"
  type        = map(string)
  default     = {}
}
