variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "managed_environment_name" {
  description = "Name of the Container Apps managed environment"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "Subnet ID for Container Apps infrastructure"
  type        = string
}

variable "container_app_name" {
  description = "Name of the container app"
  type        = string
}

variable "container_app_job_name" {
  description = "Name of the container app job"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
