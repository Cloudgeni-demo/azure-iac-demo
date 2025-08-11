output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "nsg_id" {
    value = length(azurerm_network_security_group.nsg) > 0 ? azurerm_network_security_group.nsg[0].id : null
}

output "my_ip" {
    value = "${chomp(data.http.myip.body)}"
}