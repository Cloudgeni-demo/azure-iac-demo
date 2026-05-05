variable "database_postgresql_admin_password" {
  description = "Database admin password"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    environment = "test"
    project     = "e2e-test"
  }
}
