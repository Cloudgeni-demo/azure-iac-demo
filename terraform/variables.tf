variable "database_postgresql_admin_password" {
  description = "Database admin password"
}

variable "lumen_postgres_admin_password" {
  description = "Administrator password for the lumen-staging-postgres PostgreSQL flexible server"
  sensitive   = true
  default     = "placeholder-managed-by-lifecycle-ignore"
}
