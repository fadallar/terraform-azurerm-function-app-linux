resource "azurerm_linux_function_app" "this" {
  name                          = local.name
  location                      = var.location
  resource_group_name           = var.resource_group
  storage_account_name          = var.log_storage_name
  service_plan_id               = var.service_plan_id
  storage_uses_managed_identity = true
  https_only                    = true
  enabled                       = true
  builtin_logging_enabled       = false
  functions_extension_version   = "~4"   ### Maybe add this as a variable
  tags                          = merge(var.default_tags,var.extra_tags)
  app_settings                  = merge(local.app_settings, var.app_settings)
  identity {
    ## TO-DO Investigate the choice of system, userassaigned
    type         = var.identity_ids == null ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }
  site_config {
    ## To-DO Evaluate below site config vs best practices
    ## 
    application_insights_connection_string = var.enable_appinsights ? var.application_insights_connection_string : null
    application_insights_key               = var.enable_appinsights ? var.application_insights_instrumentation_key : null
    always_on                              = true
    ftps_state                             = "Disabled"
    http2_enabled                          = true
    websockets_enabled                     = false
    use_32_bit_worker                      = false
    ip_restriction                         = var.ip_restriction
    scm_ip_restriction                     = var.ip_restriction
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
  lifecycle {
    # To-DO evaluate the reasoning behing these ignore changes
    ignore_changes = [
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      virtual_network_subnet_id
    ]
  }
}
## To-Do Review this role assignment
resource "azurerm_role_assignment" "storage" {
  for_each             = { for permision in var.azure_rbac : "${permision.scope}-${permision.role}" => permision }
  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = azurerm_linux_function_app.this.identity[0].principal_id
}

## To-Do Review the Storage Account Settings
resource "azurerm_storage_account" "storage_account" {
  name = var.log_storage_name
  resource_group_name = var.resource_group_name
  location = var.location
  account_tier = "Standard"
  account_replication_type = var.storage_account_replication
}


data "azurerm_function_app_host_keys" "this" {
  count               = var.use_private_net ? 0 : 1
  depends_on          = [azurerm_linux_function_app.this]
  name                = azurerm_linux_function_app.this.name
  resource_group_name = var.resource_group
}

data "azurerm_function_app_host_keys" "this_vnet" {
  count               = var.use_private_net ? 1 : 0
  depends_on          = [azurerm_linux_function_app.this, azurerm_app_service_virtual_network_swift_connection.this[0]]
  name                = azurerm_linux_function_app.this.name
  resource_group_name = var.resource_group
}
//Not sure we should keep the app insights configuration in this module
//
#resource "azurerm_application_insights" "this" {
#  count               = var.enable_appinsights ? 1 : 0
#  name                = "fn-${var.project}-${var.env}-${var.location}-${var.name}"
#  location            = var.location
#  resource_group_name = var.resource_group
#  application_type    = var.application_type
#  workspace_id        = var.appinsights_log_workspace_id
#  tags                = var.tags
#}