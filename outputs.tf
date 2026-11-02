output "website_url" {
  description = "URL of the website"
  value       = trimsuffix(azurerm_storage_account.site.primary_web_endpoint, "/")
}

output "storage_account_name" {
  description = "Name of the storage account with the site content"
  value       = azurerm_storage_account.site.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "blob_endpoint" {
  description = "Blob endpoint, used by the integration test to check that anonymous access is denied"
  value       = azurerm_storage_account.site.primary_blob_endpoint
}
