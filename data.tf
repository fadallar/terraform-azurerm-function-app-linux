data "azurerm_function_app_host_keys" "this" {
  count               = var.enable_private_access ? 0 : 1
  depends_on          = [azurerm_linux_function_app.this]
  name                = azurerm_linux_function_app.this.name
  resource_group_name = var.resource_group_name
}

data "azurerm_function_app_host_keys" "this_vnet" {
  count               = var.enable_private_access ? 1 : 0
  depends_on          = [azurerm_linux_function_app.this, azurerm_app_service_virtual_network_swift_connection.this[0]]
  name                = azurerm_linux_function_app.this.name
  resource_group_name = var.resource_group_name
}