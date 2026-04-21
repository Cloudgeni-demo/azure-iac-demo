# Import blocks for existing Azure resources

# Import Resource Group
import {
  to = module.resource_group.azurerm_resource_group.rg
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rgp-mywplab"
}

# Import Virtual Network
import {
  to = module.network.azurerm_virtual_network.vnet
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rgp-mywplab/providers/Microsoft.Network/virtualNetworks/vnet-mywplab"
}

# Import Subnet
import {
  to = module.network.azurerm_subnet.subnet
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rgp-mywplab/providers/Microsoft.Network/virtualNetworks/vnet-mywplab/subnets/snt-mywplab"
}

# Import Network Security Group
import {
  to = module.network.azurerm_network_security_group.nsg[0]
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rgp-mywplab/providers/Microsoft.Network/networkSecurityGroups/nsg-mywplab"
}

# Import Public IP Address
import {
  to = module.vmss.azurerm_public_ip.vmss
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rgp-mywplab/providers/Microsoft.Network/publicIPAddresses/pip-vmss-mywplab"
}

# Import Storage Account
import {
  to = module.storageaccount.azurerm_storage_account.storage_account
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rgp-mywplab/providers/Microsoft.Storage/storageAccounts/samywplab"
}

# Import PostgreSQL Flexible Server
import {
  to = module.azure-postgresql.azurerm_postgresql_flexible_server.postgresql_flexible_server
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/rgp-mywplab/providers/Microsoft.DBforPostgreSQL/flexibleServers/postgresqlf-mywplab"
}

# Import Virtual Machine Scale Set
import {
  to = module.vmss.azurerm_linux_virtual_machine_scale_set.vmss
  id = "/subscriptions/d647bcfd-4832-43d4-b02c-a82aeb620c2a/resourceGroups/RGP-MYWPLAB/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-mywplab"
}
