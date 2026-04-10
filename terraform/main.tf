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

# Container Apps Infrastructure - Imported Resources

locals {
  aca_tags = {
    demo    = "cloud-import"
    agent   = "codex"
    created = "2026-04-10"
    purpose = "aca-import"
  }
}

import {
  to = module.aca_resource_group.azurerm_resource_group.rg
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope"
}

module "aca_resource_group" {
  source = "./modules/resource_group"
  name   = "rg-aca0410f516-northeurope"
  region = "northeurope"
}

import {
  to = module.aca_network.azurerm_virtual_network.vnet
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Network/virtualNetworks/vnet-aca0410f516"
}

import {
  to = module.aca_network.azurerm_subnet.subnet
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Network/virtualNetworks/vnet-aca0410f516/subnets/snet-aca-infra"
}

module "aca_network" {
  source                  = "./modules/network"
  name                    = "aca0410f516"
  resource_group          = module.aca_resource_group.rg_name
  region                  = "northeurope"
  vnet_address_space      = ["10.42.0.0/16"]
  subnet_name             = "snet-aca-infra"
  subnet_address_prefixes = ["10.42.0.0/23"]
  service_endpoints       = []
  subnet_delegations = [{
    name         = "0"
    service_name = "Microsoft.App/environments"
    actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  }]
  security_rules = []
}

import {
  to = module.aca_storage.azurerm_storage_account.storage_account
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.Storage/storageAccounts/saaca0410f516nort"
}

module "aca_storage" {
  source                    = "./modules/storageaccount"
  resource_group            = module.aca_resource_group.rg_name
  storage_account_name      = "saaca0410f516nort"
  region                    = "northeurope"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  access_tier               = "Hot"
  enable_https_traffic_only = true
  allow_blob_public_access  = false
  min_tls_version           = "TLS1_2"
  is_hns_enabled            = false
  nfsv3_enabled             = false
  enable_lock               = false
  containers                = []
  network_rules = [
    {
      default_action             = "Allow"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
  ]
  tags = local.aca_tags
}

import {
  to = module.container_apps.azurerm_container_app_environment.managed_environment
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/managedEnvironments/cae-aca0410f516"
}

import {
  to = module.container_apps.azurerm_container_app.container_app
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/containerApps/app-aca0410f516"
}

import {
  to = module.container_apps.azurerm_container_app_job.container_app_job
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rg-aca0410f516-northeurope/providers/Microsoft.App/jobs/job-aca0410f516"
}

module "container_apps" {
  source                   = "./modules/container_apps"
  resource_group_name      = module.aca_resource_group.rg_name
  location                 = "North Europe"
  managed_environment_name = "cae-aca0410f516"
  infrastructure_subnet_id = module.aca_network.subnet_id
  container_app_name       = "app-aca0410f516"
  container_app_job_name   = "job-aca0410f516"
  tags                     = local.aca_tags
}

