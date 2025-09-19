variable "name" {
    description = "Resource Group Name"
    type = string
  
}

variable "region" {
    description = "Region of the resource group"
    type = string
  
}

variable "tags" {
    description = "Tags to apply to the resource group"
    type = map(string)
    default = {}
}