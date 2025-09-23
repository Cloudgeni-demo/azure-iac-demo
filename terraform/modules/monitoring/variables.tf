variable "resource_group_name" {
  description = "The name of the resource group in which to create the monitor resources."
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID to scope the activity log alert to."
  type        = string
}

variable "action_group_name" {
  description = "The name of the monitor action group."
  type        = string
  default     = "default-action-group"
}

variable "action_group_short_name" {
  description = "The short name of the monitor action group."
  type        = string
  default     = "defaultag"
}
