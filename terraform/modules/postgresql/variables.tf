variable "resource_group" {
  description = "resource group for azure resources"
}

variable "region" {
  description = "Region of database."
  default     = "eastus"
}

variable "resource_postgresql_name" {
  description = "Name of database resource postgresql"
}

##### Database setup
variable "database_name" {
  description = "Database name to create"
}

variable "database_sku" {
  description = "Database SKU name"
  default     = "GP_Standard_D2s_v3"
}

variable "database_postgresql_version" {
  description = "PostgreSQL version"
  default     = "13"
}

variable "backup_retention_days" {
  description = "Number of days for backup retention."
  default     = 7
}

variable "geo_redundant_backup" {
  description = "Enable/disable geo reduntant backup"
  default     = false
}

variable "database_postgresql_admin_username" {
  description = "Database admin user"
}

variable "database_postgresql_admin_password" {
  description = "Database admin password"
}

variable "vm_nsg_whitelist_ips_ports" {
  description = "List of ip's allowed to connect into database server."
  default     = []
}

variable "create_replica" {
  description = "Create a replica database"
  default     = false
}

variable "replica_database_sku" {
  description = "Replica database sku if differente from the original one"
  type        = string
  default     = ""
}

variable "replica_region" {
  description = "Region for the replica database"
  default     = "westus"
}

variable "tags" {
  description = "(Optional) Map of tags and values to apply to the resource."
  type        = map(any)
  default     = {}
}

variable "virtual_network_id" {
  description = "Vnet for the postgres server in case it will be internally linked"
  type        = string
  default     = "pg_vnet"
}

variable "subnet_id" {
  description = "(Optional)Database subnet id to inject"
  type        = string
  default     = ""
}

variable "private_dns_zone_id" {
  description = "(Optional) Database private dns zone to link"
  type        = string
  default     = ""
}

variable "storage_mb" {
  description = "Database server max size in MB"
  type        = number
  default     = 32768
}

variable "high_availability_enabled" {
  description = "Enable high availability"
  type        = bool
  default     = false
}

variable "ha_mode" {
  description = "High availability mode"
  type        = string
  default     = "ZoneRedundant"
}

variable "postgresql_zone" {
  description = "Zone to place the postgresql server"
  type        = string
  default     = ""
}

variable "postgresql_replica_zone" {
  description = "Zone to place the postgresql replica server(if exists)"
  type        = string
  default     = ""
}

variable "server_parameters" {
  description = "PostgreSQL server parameter"
  type        = list(any)
  default     = []
}
