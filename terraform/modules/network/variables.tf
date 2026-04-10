variable "name" {
    description = "Network resource Name"
    type = string
  
}

variable "region" {
    description = "Region of the network resource "
    type = string
  
}

variable "resource_group" {
  description = "Resource group for network resource"
}

variable "security_rules" {
  description = "VMSS NSG rules"
  type        = list(any)
  default     = []

}

variable "tags" {
  description = "(Optional) Map of tags and values to apply to the resource"
  type        = map(string)
  default     = {}
}

variable "service_endpoints" {
    description = "Service endpoints for the subnet"
    type = list
    default = ["Microsoft.Storage"]

}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "subnet_delegations" {
  description = "Subnet delegations"
  type = list(object({
    name         = string
    service_name = string
    actions      = list(string)
  }))
  default = []
}

variable "subnet_name" {
  description = "Override subnet name (defaults to snt-{name})"
  type        = string
  default     = null
}

variable "private_dns_name" {
    description = "private dns zone name"
    type = string
    default = "privatelink.mysql.database.azure.com"
  
}