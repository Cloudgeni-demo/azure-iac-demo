variable "region" {
  description = "Azure region for resources"
  type        = string
  default     = "westus"
}

variable "suffix" {
  description = "Suffix for resource naming"
  type        = string
  default     = "mywplab"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rgp-mywplab"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "storage_enable_lock" {
  description = "Enable resource lock on storage account"
  type        = bool
  default     = true
}

variable "vmss_sku" {
  description = "VMSS instance SKU"
  type        = string
  default     = "Standard_B2s"
}

variable "vmss_zones" {
  description = "Availability zones for VMSS"
  type        = list(string)
  default     = []
}

variable "vmss_ssh_public_key" {
  description = "SSH public key for VMSS instances"
  type        = string
}

variable "autoscaling_enabled" {
  description = "Enable autoscaling for VMSS"
  type        = bool
  default     = true
}

variable "autoscaling_capacity_default" {
  description = "Default capacity for autoscaling"
  type        = number
  default     = 3
}

variable "autoscaling_capacity_minimum" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = 3
}

variable "autoscaling_capacity_maximum" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = 4
}

variable "postgresql_sku" {
  description = "PostgreSQL database SKU"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "13"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 32768
}

variable "postgresql_backup_retention_days" {
  description = "Backup retention days for PostgreSQL"
  type        = number
  default     = 20
}

variable "postgresql_geo_redundant_backup" {
  description = "Enable geo-redundant backup for PostgreSQL"
  type        = bool
  default     = false
}

variable "postgresql_high_availability" {
  description = "Enable high availability for PostgreSQL"
  type        = bool
  default     = false
}

variable "database_postgresql_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "adminsiteswordpress"
}

variable "database_postgresql_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "postgresql_database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "wordpress"
}
