variable "database_postgresql_admin_password" {
  description = "Database admin password"
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    environment = "test"
    project     = "e2e-test"
  }
}
