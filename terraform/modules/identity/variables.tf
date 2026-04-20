variable "identity_name" {
  description = "The name of the user-assigned identity"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the identity"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the identity"
  type        = map(string)
  default     = {}
}
