// All Networking code included in the Function App ressource provider
// Networking Variables are still in the variables-networking.tf  file
//
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  count          = var.enable_private_access ? 1 : 0
  app_service_id = azurerm_linux_function_app.this.id
  subnet_id      = var.subnet_id_delegated_app_service
}

// Private Endpoint for Azure Function App
resource "azurerm_private_endpoint" "functionpep" {
  count               = var.enable_private_access == true ? 1 : 0
  name                = format("pe-%s", local.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_function_app_private_endpoint
  tags                = merge(var.default_tags, var.extra_tags)

  private_dns_zone_group {
    name                 = "function-group"
    private_dns_zone_ids = [var.private_dns_zone_ids_function_app] ### Need to align with the current DNS Private Zone
  }
  private_service_connection {
    name                           = "functionprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_function_app.this.id
    subresource_names              = ["sites"]
  }
}
//Private Endpoints for Azure Function Storage subresources
//Storage Account Blob Private Endpoint
resource "azurerm_private_endpoint" "storageblob" {
  count               = var.enable_private_access == true ? 1 : 0
  name                = format("pe-blob-%s", local.storage_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_storage_account_private_endpoint
  tags                = merge(var.default_tags, var.extra_tags)

  private_dns_zone_group {
    name                 = "storage-blob-group"
    private_dns_zone_ids = [var.private_dns_zone_ids_blob_storage]
  }
  private_service_connection {
    name                           = "blobstorageprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
  }
}
// Storage Account Queue Private Endpoint
resource "azurerm_private_endpoint" "storagequeue" {
  count               = var.enable_private_access == true ? 1 : 0
  name                = format("pe-queue-%s", local.storage_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_storage_account_private_endpoint
  tags                = merge(var.default_tags, var.extra_tags)

  private_dns_zone_group {
    name                 = "storage-queue-group"
    private_dns_zone_ids = [var.private_dns_zone_ids_queue_storage]
  }
  private_service_connection {
    name                           = "queuestorageprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["queue"]
  }
}
// Storage Account Table Private Endpoint
resource "azurerm_private_endpoint" "storagetable" {
  count               = var.enable_private_access == true ? 1 : 0
  name                = format("pe-table-%s", local.storage_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_storage_account_private_endpoint
  tags                = merge(var.default_tags, var.extra_tags)

  private_dns_zone_group {
    name                 = "storage-table-group"
    private_dns_zone_ids = [var.private_dns_zone_ids_table_storage]
  }
  private_service_connection {
    name                           = "tablestorageprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["table"]
  }
}
// Storage Account Queue File Endpoint
resource "azurerm_private_endpoint" "storagefile" {
  count               = var.enable_private_access == true ? 1 : 0
  name                = format("pe-file-%s", local.storage_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_storage_account_private_endpoint
  tags                = merge(var.default_tags, var.extra_tags)

  private_dns_zone_group {
    name                 = "storage-file-group"
    private_dns_zone_ids = [var.private_dns_zone_ids_file_storage]
  }
  private_service_connection {
    name                           = "filestorageprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["file"]
  }
}