variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "region" {
  description = "Region of the resource"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the resource"
  type        = string
}

variable "network_security_group_id" {
  description = "ID of the network security group"
  type        = string
}

variable "flow_log_name" {
  description = "Name of the flow log"
  type        = string
}

