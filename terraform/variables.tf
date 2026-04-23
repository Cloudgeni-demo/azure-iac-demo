variable "database_postgresql_admin_password" {
  description = "Database admin password"
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default = {
    environment = "test"
    project     = "e2e-test"
  }
}
