output "managed_environment_id" {
  description = "ID of the Container Apps managed environment"
  value       = azurerm_container_app_environment.managed_environment.id
}

output "container_app_id" {
  description = "ID of the container app"
  value       = azurerm_container_app.container_app.id
}

output "default_domain" {
  description = "Default domain of the managed environment"
  value       = azurerm_container_app_environment.managed_environment.default_domain
}
