// Common
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
// Function App 
variable "service_plan_id" {
  type        = string
  description = "App Service plan ID"
}
variable "enable_function_storage" {
  type = bool
  default = true
  description = "Configure a Storage account for the app"
}

variable "log_storage_name" {
  type        = string
  description = "Logs storage account name"
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

variable "identity_ids" {
  type        = list(string)
  description = "List of user assigned identity IDs"
  default     = null
}

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
  type = string
  default = null
}

variable "application_insights_instrumentation_key" {
  type = string
  default = null
}

variable "storage_account_replication" {
  type = string
  default = "LRS"
}