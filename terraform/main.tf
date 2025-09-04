provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = false
}


locals {
  region = "westus"
  tags   = {}
  suffix = "mywplab"
}

module "resource_group" {
  source = "./modules/resource_group"
  name   = "rgp-mywplab"
  region = local.region

}

module "network" {
  source         = "./modules/network"
  name           = local.suffix
  resource_group = module.resource_group.rg_name
  region         = local.region
  security_rules = [
    {
      name                       = "AllowHttp"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 80
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

  ]

}



module "storageaccount" {
  source = "./modules/storageaccount"

  resource_group            = module.resource_group.rg_name
  storage_account_name      = "sa${local.suffix}"
  region                    = local.region
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = false #Unsupported with NFS
  is_hns_enabled            = true
  nfsv3_enabled             = true
  enable_lock               = true
  containers = [
    {
      name                  = "wordpress-content"
      container_access_type = "private"
    },
    {
      name                  = "wordpress-content-bkp-weekly"
      container_access_type = "private"
    },
    {
      name                  = "wordpress-content-bkp-monthly"
      container_access_type = "private"
    }
  ]
  network_rules = [
    {
      default_action = "Deny"
      ip_rules       = [module.network.my_ip]
      virtual_network_subnet_ids = [
        module.network.subnet_id
      ]
    }
  ]
  tags = local.tags
}

module "vmss" {
  source = "./modules/vmss"
  depends_on = [
    module.storageaccount
  ]
  vmss_name                 = "vmss-${local.suffix}"
  location                  = local.region
  resource_group_name       = module.resource_group.rg_name
  sku                       = "Standard_B2s"
  zones                     = []
  upgrade_mode              = "Rolling"
  automatic_instance_repair = true
  custom_data               = filebase64("${path.root}/script.tpl")
  subnet_id                 = module.network.subnet_id
  network_security_group_id = module.network.nsg_id
  ssh_public_key            = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvQRluXF3TIK00twfnhL1dIS263+JUKXEFh6jV1xuVUFqZMKKyCEoxg+7B1juiUBLETRb1CWcoLMPYZDjyyEheC6LM5rAH2PIBYxujzNx6b82h+NEMEI5mF45HE+NPsnDdOwBTMYFYt0jGOG9/Z5Eqkv0EL5kBX75cvAbATBIVfA8Zocny9mIP/tAFjNQ8hqc+rYnjfrH8ex+p8fREofPARNC7VTPICM7+/ia2h6H/XqFvSxJm7x3pMKbYsbjjduuUIpGK5GzDBKxz+NOZCYHIAwJk1VYa/K/2ZVzqjpTQQapnJ+9GmJHuyuq4qYB/ACPphqInZRjvwG74qEVv9GzvTDH7RmZHj7f2v/XrQ6iA7iB+eJesm5OlJLn29YLwEsOWzgmPIIzkvvF9nviCPxK2zjx0nnJ9/wOEJkxSsT97BhUWWZNnyjgIRMyWQxhPvyQVv1OAeXqJdrLlRO1uC800KSOL/+LHDA5KFRq+0snk5L+P4/sssb9wnhPPBRoi2Is="
  autoscaling_enabled       = true
  capacity_default          = 3
  capacity_minimum          = 3
  capacity_maximum          = 4

  metrics_trigger = [
    {
      name                   = "Percentage CPU"
      time_grain             = "PT1M"
      statistic              = "Average"
      time_window            = "PT5M"
      time_aggregation       = "Average"
      operator               = "GreaterThan"
      threshold              = 75
      frequency              = "PT1M"
      scale_action_direction = "Increase"
      scale_action_type      = "ChangeCount"
      scale_action_value     = "1"
      scale_action_cooldown  = "PT15M"
    },
    {
      name                   = "Percentage CPU"
      time_grain             = "PT1M"
      statistic              = "Average"
      time_window            = "PT20M"
      time_aggregation       = "Average"
      operator               = "LessThan"
      threshold              = 30
      frequency              = "PT1M"
      scale_action_direction = "Decrease"
      scale_action_type      = "ChangeCount"
      scale_action_value     = "1"
      scale_action_cooldown  = "PT15M"
    }
  ]

  tags = local.tags
}


resource "azurerm_monitor_action_group" "action_group" {
  name                = "critical-alerts-action-group"
  resource_group_name = module.resource_group.rg_name
  short_name          = "critalerts"
}

resource "azurerm_monitor_activity_log_alert" "nsg_delete_alert" {
  name                = "nsg-delete-alert"
  resource_group_name = module.resource_group.rg_name
  scopes              = [module.resource_group.rg_id]
  description         = "Alert when a Network Security Group is deleted."

  criteria {
    operation_name = "Microsoft.Network/networkSecurityGroups/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}

module "azure-postgresql" {
  source                             = "./modules/postgresql"
  resource_group                     = module.resource_group.rg_name
  region                             = local.region
  resource_postgresql_name           = "postgresqlf-${local.suffix}"
  database_name                      = "wordpress"
  database_sku                       = "GP_Standard_D2s_v3"
  database_postgresql_version        = "13"
  storage_mb                         = 32768
  backup_retention_days              = 20
  geo_redundant_backup               = false
  high_availability_enabled          = false
  postgresql_zone                    = ""
  database_postgresql_admin_username = "adminsiteswordpress"
  database_postgresql_admin_password = var.database_postgresql_admin_password
  tags                               = local.tags
  vm_nsg_whitelist_ips_ports = [{
    "name"      = "vmss_ip"
    "source_ip" = module.vmss.lb_ip

  }]
  server_parameters = [
    {
      name  = "log_statement"
      value = "all"
    }
  ]
}

