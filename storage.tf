# The static website endpoint serves the $web container anonymously over HTTPS.
# Everything else in the account stays private.
resource "azurerm_storage_account" "site" {
  #checkov:skip=CKV_AZURE_59:The static website endpoint must be reachable from the internet
  #checkov:skip=CKV_AZURE_35:The static website endpoint must be reachable from the internet
  #checkov:skip=CKV2_AZURE_33:Private endpoint would make the public website unreachable
  #checkov:skip=CKV_AZURE_206:LRS is enough for a demo website
  #checkov:skip=CKV_AZURE_33:Queue service is not used
  #checkov:skip=CKV2_AZURE_1:Encrypted with Microsoft-managed keys, customer-managed keys are out of scope for the demo
  #checkov:skip=CKV2_AZURE_40:The azurerm provider needs shared key access to manage the static website
  #checkov:skip=CKV2_AZURE_41:SAS tokens are not used
  name                              = "${substr(replace(var.name_prefix, "-", ""), 0, 12)}site${random_string.suffix.result}"
  location                          = azurerm_resource_group.this.location
  resource_group_name               = azurerm_resource_group.this.name
  account_kind                      = "StorageV2"
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = true
  tags                              = local.tags

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.site.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

resource "azurerm_storage_blob" "pages" {
  for_each = toset(["index.html", "404.html"])

  name                 = each.key
  storage_container_id = "${azurerm_storage_account.site.id}/blobServices/default/containers/$web"
  type                 = "Block"
  source               = "${path.module}/site/${each.key}"
  content_md5          = filemd5("${path.module}/site/${each.key}")
  content_type         = "text/html; charset=utf-8"

  depends_on = [azurerm_storage_account_static_website.site]
}

# Access logs of the blob service (includes static website requests)
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name_prefix}-static-website-logs"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = var.advanced_settings.log_retention_days
  tags                = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "blob" {
  name                       = "access-logs"
  target_resource_id         = "${azurerm_storage_account.site.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }
}
