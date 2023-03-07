resource "azurerm_linux_function_app" "this" {
  depends_on                 = [azurerm_storage_account.storage_account,azurerm_storage_share.this]
  name                       = local.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  storage_account_name       = azurerm_storage_account.storage_account.name
  #storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = var.service_plan_id
  storage_uses_managed_identity = var.storage_uses_managed_identity
  https_only                      = var.https_only
  enabled                         = true
  builtin_logging_enabled         = var.builtin_logging_enabled
  functions_extension_version     = var.functions_extension_version
  tags                            = merge(var.default_tags, var.extra_tags)
  app_settings                    = merge(local.app_settings, var.app_settings)
  key_vault_reference_identity_id = var.key_vault_identity_id
  identity {
    type         = var.identity_ids == null ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }
  site_config {
    ## To-DO Evaluate below site config vs best practices
    ## 
    #application_insights_connection_string = var.enable_appinsights ? var.application_insights_connection_string : null
    always_on = true
    #ftps_state                             = "Disabled"
    #http2_enabled                          = true
    #websockets_enabled                     = false
    #use_32_bit_worker                      = false
    #ip_restriction                         = var.ip_restriction
    #scm_ip_restriction                     = var.ip_restriction
    application_stack {
      dotnet_version              = local.application_stack.dotnet_version
      use_dotnet_isolated_runtime = local.application_stack.use_dotnet_isolated_runtime
      java_version                = local.application_stack.java_version
      node_version                = local.application_stack.node_version
      python_version              = local.application_stack.python_version
      powershell_core_version     = local.application_stack.powershell_core_version
      use_custom_runtime          = local.application_stack.use_custom_runtime
    }
  }
  #lifecycle {
  #  # To-DO evaluate the reasoning behing these ignore changes
  #  ignore_changes = [
  #    tags["hidden-link: /app-insights-conn-string"],
  #    tags["hidden-link: /app-insights-instrumentation-key"],
  #    tags["hidden-link: /app-insights-resource-id"],
  #    virtual_network_subnet_id
  #  ]
  #}
}
## To-Do Review this role assignment
#resource "azurerm_role_assignment" "storage" {
#  scope                = azurerm_storage_account.storage_account.id
#  role_definition_name = "Storage Blob Data Owner"
#  principal_id         = azurerm_linux_function_app.this.identity[0].principal_id
#}
#
### To-DO Create KeyVault Secret with Azure File Connection String
### And INject it in app-settings
resource "azurerm_storage_share" "this" {
  name                 = "functionshare"
  storage_account_name = azurerm_storage_account.storage_account.name
}

resource "azurerm_storage_account" "storage_account" {
  name                             = local.storage_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = var.storage_account_replication
  public_network_access_enabled    = false
  cross_tenant_replication_enabled = false
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = true
  enable_https_traffic_only        = true
  access_tier                      = "Hot"
}


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