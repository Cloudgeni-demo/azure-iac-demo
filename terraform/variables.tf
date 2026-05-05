variable "database_postgresql_admin_password" {
  description = "Database admin password"
}

variable "tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    environment = "test"
    project     = "e2e-test"
  }
}
