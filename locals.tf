#locals {
#  default_app_settings = {
#    #WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = azurerm_storage_account.storage_account.primary_connection_string
#    #WEBSITE_DNS_SERVER = "168.63.129.16"
#    #WEBSITE_CONTENTOVERVNET = 1
#    #WEBSITE_CONTENTSHARE ="functionshare"
#  }
#  application_stack_struct = {
#    dotnet_version              = null
#    use_dotnet_isolated_runtime = null
#    java_version                = null
#    node_version                = null
#    python_version              = null
#    powershell_core_version     = null
#    use_custom_runtime          = null
#  }
#  application_stack = merge(local.application_stack_struct, var.application_stack)
#}
#
#APPLICATIONINSIGHTS_CONNECTION_STRING
#AzureWebJobsDisableHomepage
#AzureWebJobsStorage
#FUNCTION_APP_EDIT_MODE
#FUNCTIONS_EXTENSION_VERSION
#FUNCTIONS_WORKER_RUNTIME e.g java
#JAVA_OPTS  only for Premium and dedicated
#WEBSITE_CONTENTAZUREFILECONNECTIONSTRING

locals {
  #is_consumption = data.azurerm_service_plan.plan.sku_name == "Y1"
  is_consumption = false # TODO check how to test it in our case

  default_site_config = {
    always_on                              = !local.is_consumption
    application_insights_connection_string = enable_appinsights ? var.app_insights.connection_string : null
    application_insights_key               = enable_appinsights ? var.app_insights.instrumentation_key : null
  }

  site_config = merge(local.default_site_config, var.site_config)

  #app_insights = try(data.azurerm_application_insights.app_insights[0], try(azurerm_application_insights.app_insights[0], {}))

  default_application_settings = merge(
    var.application_zip_package_path != null ? {
      # MD5 as query to force function restart on change
      WEBSITE_RUN_FROM_PACKAGE = local.zip_package_url
    } : {},
    substr(lookup(local.site_config, "linux_fx_version", ""), 0, 7) == "DOCKER|" ? {
      FUNCTIONS_WORKER_RUNTIME            = null
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    } : {},
  )

  default_ip_restrictions_headers = {
    x_azure_fdid      = null
    x_fd_health_probe = null
    x_forwarded_for   = null
    x_forwarded_host  = null
  }

  ip_restriction_headers = var.ip_restriction_headers != null ? [merge(local.default_ip_restrictions_headers, var.ip_restriction_headers)] : []

  cidrs = [for cidr in var.authorized_ips : {
    name                      = "ip_restriction_cidr_${join("", [1, index(var.authorized_ips, cidr)])}"
    ip_address                = cidr
    virtual_network_subnet_id = null
    service_tag               = null
    subnet_id                 = null
    priority                  = join("", [1, index(var.authorized_ips, cidr)])
    action                    = "Allow"
    headers                   = local.ip_restriction_headers
  }]

  subnets = [for subnet in var.authorized_subnet_ids : {
    name                      = "ip_restriction_subnet_${join("", [1, index(var.authorized_subnet_ids, subnet)])}"
    ip_address                = null
    virtual_network_subnet_id = subnet
    service_tag               = null
    subnet_id                 = subnet
    priority                  = join("", [1, index(var.authorized_subnet_ids, subnet)])
    action                    = "Allow"
    headers                   = local.ip_restriction_headers
  }]

  service_tags = [for service_tag in var.authorized_service_tags : {
    name                      = "service_tag_restriction_${join("", [1, index(var.authorized_service_tags, service_tag)])}"
    ip_address                = null
    virtual_network_subnet_id = null
    service_tag               = service_tag
    subnet_id                 = null
    priority                  = join("", [1, index(var.authorized_service_tags, service_tag)])
    action                    = "Allow"
    headers                   = local.ip_restriction_headers
  }]

  scm_ip_restriction_headers = var.scm_ip_restriction_headers != null ? [merge(local.default_ip_restrictions_headers, var.scm_ip_restriction_headers)] : []

  scm_cidrs = [for cidr in var.scm_authorized_ips : {
    name                      = "scm_ip_restriction_cidr_${join("", [1, index(var.scm_authorized_ips, cidr)])}"
    ip_address                = cidr
    virtual_network_subnet_id = null
    service_tag               = null
    subnet_id                 = null
    priority                  = join("", [1, index(var.scm_authorized_ips, cidr)])
    action                    = "Allow"
    headers                   = local.scm_ip_restriction_headers
  }]

  scm_subnets = [for subnet in var.scm_authorized_subnet_ids : {
    name                      = "scm_ip_restriction_subnet_${join("", [1, index(var.scm_authorized_subnet_ids, subnet)])}"
    ip_address                = null
    virtual_network_subnet_id = subnet
    service_tag               = null
    subnet_id                 = subnet
    priority                  = join("", [1, index(var.scm_authorized_subnet_ids, subnet)])
    action                    = "Allow"
    headers                   = local.scm_ip_restriction_headers
  }]

  scm_service_tags = [for service_tag in var.scm_authorized_service_tags : {
    name                      = "scm_service_tag_restriction_${join("", [1, index(var.scm_authorized_service_tags, service_tag)])}"
    ip_address                = null
    virtual_network_subnet_id = null
    service_tag               = service_tag
    subnet_id                 = null
    priority                  = join("", [1, index(var.scm_authorized_service_tags, service_tag)])
    action                    = "Allow"
    headers                   = local.scm_ip_restriction_headers
  }]

  # # If no VNet integration, allow Function App outbound public IPs

  function_outbound_ips = var.function_app_vnet_integration_subnet_id == null ? distinct(concat(azurerm_linux_function_app.this.possible_outbound_ip_address_list, azurerm_linux_function_app.linux_function.outbound_ip_address_list)) : []
  #
  # # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules#ip_rules
  # # > Small address ranges using "/31" or "/32" prefix sizes are not supported. These ranges should be configured using individual IP address rules without prefix specified.

  storage_ips = distinct(flatten([for cidr in distinct(concat(local.function_outbound_ips, var.storage_account_authorized_ips)) :
    length(regexall("/3[12]$", cidr)) > 0 ? [cidrhost(cidr, 0), cidrhost(cidr, -1)] : [cidr]
  ]))

  ### TO DO 
  is_local_zip = length(regexall("^(http(s)?|ftp)://", var.application_zip_package_path != null ? var.application_zip_package_path : 0)) == 0
  zip_package_url = (
    var.application_zip_package_path != null && local.is_local_zip ?
    format("%s%s&md5=%s", azurerm_storage_blob.package_blob[0].url, try(data.azurerm_storage_account_sas.package_sas["enabled"].sas, "?"), filemd5(var.application_zip_package_path)) :
    var.application_zip_package_path
  )

  storage_account_output = data.azurerm_storage_account.storage
}