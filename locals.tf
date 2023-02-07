locals {
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = "true"
    JAVA_OPTS                           = "-Dlog4j2.formatMsgNoLookups=true"
    LOG4J_FORMAT_MSG_NO_LOOKUPS         = "true"
    WEBSITE_USE_PLACEHOLDER             = "0"
    AZURE_LOG_LEVEL                     = "info"
    AzureWebJobsDisableHomepage         = "true"
    AzureWebJobsStorage__accountName    = local.storage_account_name
    ### To-Do review below naming structure 
    ##  AzureFunctionsWebHost__hostid       = substr("fn-${var.project}-${var.env}-${var.location}-${var.name}", -32, -1)
  }
  application_stack_struct = {
    dotnet_version              = null
    use_dotnet_isolated_runtime = null
    java_version                = null
    node_version                = null
    python_version              = null
    powershell_core_version     = null
    use_custom_runtime          = null
  }
  application_stack = merge(local.application_stack_struct, var.application_stack)
}

