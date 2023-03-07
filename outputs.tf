output "primary_key" {
  value       = var.enable_private_access ? data.azurerm_function_app_host_keys.this_vnet[0].primary_key : data.azurerm_function_app_host_keys.this[0].primary_key
  description = "Function app primary key"
  sensitive   = true
}

output "id" {
  value       = azurerm_linux_function_app.this.id
  description = "Function app ID"
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
