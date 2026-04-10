module "resource_group" {
  source = "./modules/resource_group"
  name   = var.resource_group_name
  region = var.region
}

module "network" {
  source         = "./modules/network"
  name           = var.suffix
  resource_group = module.resource_group.rg_name
  region         = var.region
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
  storage_account_name      = "sa${var.suffix}"
  region                    = var.region
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_replication_type
  account_kind              = "StorageV2"
  enable_https_traffic_only = false #Unsupported with NFS
  is_hns_enabled            = true
  nfsv3_enabled             = true
  enable_lock               = var.storage_enable_lock
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
  tags = var.tags
}

module "vmss" {
  source = "./modules/vmss"
  depends_on = [
    module.storageaccount
  ]
  vmss_name                 = "vmss-${var.suffix}"
  location                  = var.region
  resource_group_name       = module.resource_group.rg_name
  sku                       = var.vmss_sku
  zones                     = var.vmss_zones
  upgrade_mode              = "Rolling"
  automatic_instance_repair = true
  custom_data               = filebase64("${path.root}/script.tpl")
  subnet_id                 = module.network.subnet_id
  network_security_group_id = module.network.nsg_id
  ssh_public_key            = var.vmss_ssh_public_key
  autoscaling_enabled       = var.autoscaling_enabled
  capacity_default          = var.autoscaling_capacity_default
  capacity_minimum          = var.autoscaling_capacity_minimum
  capacity_maximum          = var.autoscaling_capacity_maximum

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

  tags = var.tags
}


module "azure-postgresql" {
  source                             = "./modules/postgresql"
  resource_group                     = module.resource_group.rg_name
  region                             = var.region
  resource_postgresql_name           = "postgresqlf-${var.suffix}"
  database_name                      = var.postgresql_database_name
  database_sku                       = var.postgresql_sku
  database_postgresql_version        = var.postgresql_version
  storage_mb                         = var.postgresql_storage_mb
  backup_retention_days              = var.postgresql_backup_retention_days
  geo_redundant_backup               = var.postgresql_geo_redundant_backup
  high_availability_enabled          = var.postgresql_high_availability
  postgresql_zone                    = ""
  database_postgresql_admin_username = var.database_postgresql_admin_username
  database_postgresql_admin_password = var.database_postgresql_admin_password
  tags                               = var.tags
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

