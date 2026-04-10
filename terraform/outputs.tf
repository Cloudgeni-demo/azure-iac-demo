output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.rg_name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.network.vnet_id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = module.network.subnet_id
}

output "vmss_id" {
  description = "ID of the VMSS"
  value       = module.vmss.vmss_id
}

output "load_balancer_ip" {
  description = "Load balancer public IP"
  value       = module.vmss.lb_ip
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.azure-postgresql.postgresql_fqdn
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = var.postgresql_database_name
}
