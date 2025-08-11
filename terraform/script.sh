# Vars
SUBSCRIPTION_ID="d647bcfd-4832-43d4-b02c-a82aeb620c2a"
RG="rgp-mywplab"
SUFFIX="mywplab"
SA="samywplab"
VMSS="vmss-${SUFFIX}"
LB="lb-${VMSS}"
PIP="pip-${VMSS}"
PG="postgresqlf-${SUFFIX}"

# Resource Group
terraform import module.resource_group.azurerm_resource_group.rg "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}"

# Network
terraform import module.network.azurerm_virtual_network.vnet "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Network/virtualNetworks/vnet-${SUFFIX}"
terraform import module.network.azurerm_subnet.subnet "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Network/virtualNetworks/vnet-${SUFFIX}/subnets/snt-${SUFFIX}"
# Only if security_rules was non-empty (it is in your config)
terraform import 'module.network.azurerm_network_security_group.nsg[0]' "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Network/networkSecurityGroups/nsg-${SUFFIX}"

# Storage Account + Containers
terraform import module.storageaccount.azurerm_storage_account.storage_account "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Storage/storageAccounts/${SA}"
terraform import 'module.storageaccount.azurerm_storage_container.container[0]' "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Storage/storageAccounts/${SA}/blobServices/default/containers/wordpress-content"
terraform import 'module.storageaccount.azurerm_storage_container.container[1]' "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Storage/storageAccounts/${SA}/blobServices/default/containers/wordpress-content-bkp-weekly"
terraform import 'module.storageaccount.azurerm_storage_container.container[2]' "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Storage/storageAccounts/${SA}/blobServices/default/containers/wordpress-content-bkp-monthly"

# VMSS + LB
terraform import module.vmss.azurerm_public_ip.vmss "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Network/publicIPAddresses/${PIP}"
terraform import module.vmss.azurerm_lb.vmss "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Network/loadBalancers/${LB}"
terraform import module.vmss.azurerm_lb_backend_address_pool.bpepool "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Network/loadBalancers/${LB}/backendAddressPools/BackEndAddressPool"
terraform import module.vmss.azurerm_lb_probe.vmss "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Network/loadBalancers/${LB}/probes/running-probe"
terraform import module.vmss.azurerm_lb_rule.lbnatrule "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Network/loadBalancers/${LB}/loadBalancingRules/http"
terraform import module.vmss.azurerm_linux_virtual_machine_scale_set.vmss "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Compute/virtualMachineScaleSets/${VMSS}"
terraform import 'module.vmss.azurerm_monitor_autoscale_setting.vmss_autoscale[0]' "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.Insights/autoScaleSettings/${VMSS}"

# PostgreSQL Flexible Server + DB + firewall + parameter
terraform import module.azure-postgresql.azurerm_postgresql_flexible_server.postgresql_flexible_server "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.DBforPostgreSQL/flexibleServers/${PG}"
terraform import module.azure-postgresql.azurerm_postgresql_flexible_server_database.postgresql_database "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.DBforPostgreSQL/flexibleServers/${PG}/databases/wordpress"
terraform import 'module.azure-postgresql.azurerm_postgresql_flexible_server_firewall_rule.postgresql_firewall_rule[0]' "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.DBforPostgreSQL/flexibleServers/${PG}/firewallRules/vmss_ip"
terraform import 'module.azure-postgresql.azurerm_postgresql_flexible_server_configuration.server_parameters[0]' "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.DBforPostgreSQL/flexibleServers/${PG}/configurations/log_statement"
