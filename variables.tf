#### Common
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "stack" {
  description = "Stack name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group the resources will belong to"
  type        = string
}

variable "location" {
  description = "Azure location for Key Vault."
  type        = string
}

variable "location_short" {
  description = "Short string for Azure location."
  type        = string
}

#### Function App  Base 
variable "service_plan_id" {
  type        = string
  description = "App Service plan ID"
}

variable "application_type" {
  type        = string
  description = "Application type (java, python, etc)"
  default     = "java"
}

variable "application_stack" {
  type        = map(string)
  description = "Application stack"
  default = {
    java_version = "11"
  }
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Application setting"
}

variable "azure_rbac" {
  type        = list(map(string))
  description = "Azure RBAC permision map (scope, role)"
  default     = []
}

variable "key_vault_reference_identity_id" {
  type        = string
  description = "The User Assigned Identity ID used for accessing KeyVault secrets. The identity must be assigned to the application in the identity Ids list."
  default     = null
}

variable "identity_type" { ###TO DO 
  description = ""
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  type        = list(string)
  description = "List of user assigned identity IDs"
  default     = null
}

variable "functions_extension_version" {
  description = "Function Runtime Version"
  default     = "~4"
}

### Application Insights Related

variable "enable_appinsights" {
  type        = bool
  description = "Enable application insights"
  default     = true
}

variable "appinsights_log_workspace_id" {
  type        = string
  description = "Resource ID of Log Analytics Workspace"
  default     = null
}

variable "application_insights_connection_string" {
  type    = string
  default = null
}

variable "application_insights_instrumentation_key" {
  type    = string
  default = null
}


variable "https_only" {
  description = "Can the Function App only be accessed via HTTPS?"
  default     = true
}

variable "builtin_logging_enabled" {
  description = "Should built in logging be enabled. Configures AzureWebJobsDashboard app setting based on the configured storage setting"
  default     = false
}

variable "client_certificate_enabled" {
  description = "Whether the Function App uses client certificates."
  type        = bool
  default     = null ## Change to false
}

variable "client_certificate_mode" {
  description = "The mode of the Function App's client certificates requirement for incoming requests. Possible values are `Required`, `Optional`, and `OptionalInteractiveUser`."
  type        = string
  default     = null
}

###  Site Config Related
variable "site_config" {
  description = "Site config for Function App. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#site_config. IP restriction attribute is not managed in this block."
  type        = any
  default     = {}
}

variable "application_zip_package_path" {
  description = "Local or remote path of a zip package to deploy on the Function App."
  type        = string
  default     = null
}

variable "authorized_ips" {
  description = "IPs restriction for Function in CIDR format. See documentation https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app#ip_restriction"
  type        = list(string)
  default     = []
}

variable "authorized_subnet_ids" {
  description = "Subnets restriction for Function App. See documentation https://www.terraform.io/docs/providers/azurerm/r/function_app.html#ip_restriction"
  type        = list(string)
  default     = []
}

variable "ip_restriction_headers" {
  description = "IPs restriction headers for Function. See documentation https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app#headers"
  type        = map(list(string))
  default     = null
}

variable "scm_authorized_ips" {
  description = "SCM IPs restriction for Function App. See documentation https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app#scm_ip_restriction"
  type        = list(string)
  default     = []
}

variable "scm_authorized_subnet_ids" {
  description = "SCM subnets restriction for Function App. See documentation https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app#scm_ip_restriction"
  type        = list(string)
  default     = []
}

variable "scm_ip_restriction_headers" {
  description = "IPs restriction headers for Function App. See documentation https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app#scm_ip_restriction"
  type        = map(list(string))
  default     = null
}

variable "scm_authorized_service_tags" {
  description = "SCM Service Tags restriction for Function App. See documentation https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app#scm_ip_restriction"
  type        = list(string)
  default     = []
}

variable "authorized_service_tags" {
  description = "Service Tags restriction for Function App. See documentation https://www.terraform.io/docs/providers/azurerm/r/function_app.html#ip_restriction"
  type        = list(string)
  default     = []
}


variable "storage_account_authorized_ips" {
  description = ""
  type        = list(string)
  default     = []
}


### Storage Account Related

variable "storage_account_replication" {
  type    = string
  default = "LRS"
  validation {
    condition     = contains(["LRS", "ZRS"], var.storage_account_replication)
    error_message = "Invalid variable: ${var.storage_account_replication}. Replication type not valid we only support LRS or ZRS"
  }
}

variable "storage_uses_managed_identity" {
  description = "Use user managed identities for function storage account "
  default     = true
  type        = bool
}

variable "storage_public_access_enabled" {
  description = "Enable public access for the storage account"
  default     = false
  type        = bool
}

variable "storage_allow_nested_item_to_be_public" {
  description = "Allow storage nested item to be public"
  default     = false
  type        = bool
}