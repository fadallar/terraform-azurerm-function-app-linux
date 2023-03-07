locals {
  app_settings = {
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