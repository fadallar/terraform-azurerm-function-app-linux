#variable "ip_restriction" {
#  description = "Firewall settings for the function app"
#  type = list(object({
#    name                      = string
#    ip_address                = string
#    service_tag               = string
#    virtual_network_subnet_id = string
#    priority                  = string
#    action                    = string
#    headers = list(object({
#      x_azure_fdid      = list(string)
#      x_fd_health_probe = list(string)
#      x_forwarded_for   = list(string)
#      x_forwarded_host  = list(string)
#    }))
#  }))
#  default = [
#    {
#      name                      = "allow_azure"
#      ip_address                = null
#      service_tag               = "AzureCloud"
#      virtual_network_subnet_id = null
#      priority                  = "100"
#      action                    = "Allow"
#      headers                   = null
#    }
#  ]
#}

variable "vnet_route_all_enabled" {
  type        = bool
  description = "Enable VNET route all. Only relevant if VNET integration is used"
  default     = false
}

variable "enable_private_access" {
  type        = bool
  description = "Use private network injection"
  default     = true
}
//Subnet References
variable "subnet_id_delegated_app_service" {
  type        = string
  description = "Subnet ID for the delegated subnet to function app"
  default     = ""
}
// Private endpoints
variable "subnet_id_function_app_private_endpoint" {
  type    = string
  default = ""
}

variable "subnet_id_storage_account_private_endpoint" {
  type    = string
  default = ""
}
// Private DNS Zones
variable "private_dns_zone_ids_function_app" {
  type    = string
  default = ""
}

variable "private_dns_zone_ids_blob_storage" {
  type    = string
  default = ""
}

variable "private_dns_zone_ids_queue_storage" {
  type    = string
  default = ""
}

variable "private_dns_zone_ids_table_storage" {
  type    = string
  default = ""
}

variable "private_dns_zone_ids_file_storage" {
  type    = string
  default = ""
}