output "id" {
  value       = azurerm_linux_function_app.this.id
  description = "Function app ID"
}

output "name" {
  value       = azurerm_linux_function_app.this.name
  description = "Function app name"
}

output "identity" {
  value       = azurerm_linux_function_app.this.identity[*]
  description = "Function app Managed Identity"
}

output "outbound_ip_address_list" {
  value       = azurerm_linux_function_app.this.outbound_ip_address_list
  description = "Function app outbound IP address list"
}

output "storage_primary_access_key" {
  value       = azurerm_storage_account.storage_account.primary_access_key
  description = "Storage Account primary access key"
  sensitive   = true
}

output "storage_secondary_access_key" {
  value       = azurerm_storage_account.storage_account.secondary_access_key
  description = "Storage Account secondary access key"
  sensitive   = true
}




#custom_domain_verification_id - The identifier used by App Service to perform domain ownership verification via DNS TXT record.
#default_hostname - The default hostname of the Linux Function App.
#kind - The Kind value for this Linux Function App.
#outbound_ip_addresses - A comma separated list of outbound IP addresses as a string. For example 52.23.25.3,52.143.43.12.
#possible_outbound_ip_address_list - A list of possible outbound IP addresses, not all of which are necessarily in use. This is a superset of outbound_ip_address_list. For example ["52.23.25.3", "52.143.43.12"].
#possible_outbound_ip_addresses - A comma separated list of possible outbound IP addresses as a string. For example 52.23.25.3,52.143.43.12,52.143.43.17. This is a superset of outbound_ip_addresses. For example ["52.23.25.3", "52.143.43.12","52.143.43.17"].
#site_credential - A site_credential block as defined below.

