resource "azurerm_container_app_environment" "managed_environment" {
  name                               = var.managed_environment_name
  location                           = var.location
  resource_group_name                = var.resource_group_name
  infrastructure_subnet_id           = var.infrastructure_subnet_id
  internal_load_balancer_enabled     = false

  tags = var.tags
}

resource "azurerm_container_app" "container_app" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.managed_environment.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.container_app_name
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.tags
}
