resource "azurerm_linux_function_app" "this" {
  depends_on          = [azurerm_storage_account.storage_account]
  name                = local.name
  location            = var.location
  resource_group_name = var.resource_group_name
  enabled             = true

  service_plan_id = var.service_plan_id

  storage_account_name          = azurerm_storage_account.storage_account.name
  storage_account_access_key    = !var.storage_uses_managed_identity ? azurerm_storage_account.storage_account.primary_access_key : null
  storage_uses_managed_identity = var.storage_uses_managed_identity ? true : null

  functions_extension_version = var.functions_extension_version

  https_only                 = var.https_only
  client_certificate_enabled = var.client_certificate_enabled
  client_certificate_mode    = var.client_certificate_mode

  builtin_logging_enabled = var.builtin_logging_enabled

  key_vault_reference_identity_id = var.key_vault_reference_identity_id

  app_settings = merge(
    local.default_application_settings,
    var.app_settings,
  )

  dynamic "site_config" {
    for_each = [local.site_config]
    content {
      always_on                         = lookup(site_config.value, "always_on", null)
      api_definition_url                = lookup(site_config.value, "api_definition_url", null)
      api_management_api_id             = lookup(site_config.value, "api_management_api_id", null)
      app_command_line                  = lookup(site_config.value, "app_command_line", null)
      app_scale_limit                   = lookup(site_config.value, "app_scale_limit", null)
      default_documents                 = lookup(site_config.value, "default_documents", null)
      ftps_state                        = lookup(site_config.value, "ftps_state", "Disabled")
      health_check_path                 = lookup(site_config.value, "health_check_path", null)
      health_check_eviction_time_in_min = lookup(site_config.value, "health_check_eviction_time_in_min", null)
      http2_enabled                     = lookup(site_config.value, "http2_enabled", null)
      load_balancing_mode               = lookup(site_config.value, "load_balancing_mode", null)
      managed_pipeline_mode             = lookup(site_config.value, "managed_pipeline_mode", null)
      minimum_tls_version               = lookup(site_config.value, "minimum_tls_version", lookup(site_config.value, "min_tls_version", "1.2"))
      remote_debugging_enabled          = lookup(site_config.value, "remote_debugging_enabled", false)
      remote_debugging_version          = lookup(site_config.value, "remote_debugging_version", null)
      runtime_scale_monitoring_enabled  = lookup(site_config.value, "runtime_scale_monitoring_enabled", null)
      websockets_enabled                = lookup(site_config.value, "websockets_enabled", false)

      application_insights_connection_string = var.application_insights_connection_string
      application_insights_key               = var.application_insights_instrumentation_key

      pre_warmed_instance_count = lookup(site_config.value, "pre_warmed_instance_count", null)
      elastic_instance_minimum  = lookup(site_config.value, "elastic_instance_minimum", null)
      worker_count              = lookup(site_config.value, "worker_count", null)

      vnet_route_all_enabled = lookup(site_config.value, "vnet_route_all_enabled", var.subnet_id_delegated_app_service != null)

      ip_restriction              = concat(local.subnets, local.cidrs, local.service_tags)
      scm_type                    = lookup(site_config.value, "scm_type", null)
      scm_use_main_ip_restriction = length(var.scm_authorized_ips) > 0 || var.scm_authorized_subnet_ids != null ? false : true
      scm_ip_restriction          = concat(local.scm_subnets, local.scm_cidrs, local.scm_service_tags)

      dynamic "application_stack" {
        for_each = lookup(site_config.value, "application_stack", null) == null ? [] : ["application_stack"]
        content {
          dynamic "docker" {
            for_each = lookup(local.site_config.application_stack, "docker", null) == null ? [] : ["docker"]
            content {
              registry_url      = local.site_config.application_stack.docker.registry_url
              image_name        = local.site_config.application_stack.docker.image_name
              image_tag         = local.site_config.application_stack.docker.image_tag
              registry_username = lookup(local.site_config.application_stack.docker, "registry_username", null)
              registry_password = lookup(local.site_config.application_stack.docker, "registry_password", null)
            }
          }

          dotnet_version              = lookup(local.site_config.application_stack, "dotnet_version", null)
          use_dotnet_isolated_runtime = lookup(local.site_config.application_stack, "use_dotnet_isolated_runtime", null)

          java_version            = lookup(local.site_config.application_stack, "java_version", null)
          node_version            = lookup(local.site_config.application_stack, "node_version", null)
          python_version          = lookup(local.site_config.application_stack, "python_version", null)
          powershell_core_version = lookup(local.site_config.application_stack, "powershell_core_version", null)

          use_custom_runtime = lookup(local.site_config.application_stack, "use_custom_runtime", null)
        }
      }

      dynamic "cors" {
        for_each = lookup(site_config.value, "cors", null) != null ? ["cors"] : []
        content {
          allowed_origins     = lookup(site_config.value.cors, "allowed_origins", [])
          support_credentials = lookup(site_config.value.cors, "support_credentials", false)
        }
      }
    }
  }


  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
  }
  tags = merge(var.default_tags, var.extra_tags)


  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      virtual_network_subnet_id, ### Refer to https://github.com/hashicorp/terraform-provider-azurerm/issues/17930
      app_settings.WEBSITE_RUN_FROM_ZIP,
      app_settings.WEBSITE_RUN_FROM_PACKAGE,
      app_settings.MACHINEKEY_DecryptionKey,
      app_settings.WEBSITE_CONTENTAZUREFILECONNECTIONSTRING,
      app_settings.WEBSITE_CONTENTSHARE
    ]
  }

}

resource "azurerm_storage_account" "storage_account" {
  name                             = local.storage_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = var.storage_account_replication
  public_network_access_enabled    = var.storage_public_access_enabled
  cross_tenant_replication_enabled = false
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = var.storage_allow_nested_item_to_be_public
  shared_access_key_enabled        = true
  enable_https_traffic_only        = true
  access_tier                      = "Hot"
}

