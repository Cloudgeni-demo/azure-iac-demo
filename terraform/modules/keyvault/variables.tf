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

variable "user_assigned_identity" {
    type = object({
        id = string
        principal_id = string
        tenant_id = string
    })
}

variable "key_name" {
  description = "The name of the key vault key"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the key vault"
  type        = map(string)
  default     = {}
}
