variable "database_postgresql_admin_password" {
  description = "Database admin password"
}

variable "second_owner_principal_id" {
  description = "The principal ID of the second owner to be assigned to the subscription."
  type        = string
}
