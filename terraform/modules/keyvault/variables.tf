variable "name" {
  type        = string
  description = "The name of the key vault."
}

variable "region" {
  type        = string
  description = "The region where the key vault will be created."
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group where the key vault will be created."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the key vault."
  default     = {}
}
