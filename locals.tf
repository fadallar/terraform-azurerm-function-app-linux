locals {
  app_settings = {
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = azurerm_storage_account.storage_account.primary_access_key

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

#APPLICATIONINSIGHTS_CONNECTION_STRING
#AzureWebJobsDisableHomepage
#AzureWebJobsStorage
#FUNCTION_APP_EDIT_MODE
#FUNCTIONS_EXTENSION_VERSION
#FUNCTIONS_WORKER_RUNTIME e.g java
#JAVA_OPTS  only for Premium and dedicated
#WEBSITE_CONTENTAZUREFILECONNECTIONSTRING