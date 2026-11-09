# Unit tests: plan only, providers are mocked. No cloud account, no cost.
# Run: tofu test -test-directory=tests/unit
# Test case catalog: tests/README.md

# Some arguments are validated as Azure resource IDs, so mocked IDs must look real.
mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksite"
      primary_web_endpoint = "https://mocksite.z6.web.core.windows.net/"
    }
  }

  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.OperationalInsights/workspaces/mock-law"
    }
  }
}

# U-01
run "defaults_are_valid" {
  command = plan

  assert {
    condition = (
      local.tags["Environment"] == "demo" &&
      local.tags["ManagedBy"] == "opentofu" &&
      local.tags["Project"] == var.name_prefix &&
      local.tags["Repository"] != ""
    )
    error_message = "Default tags are missing or wrong."
  }
}

# U-02
run "invalid_name_prefix_is_rejected" {
  command = plan

  variables {
    name_prefix = "Invalid_Prefix"
  }

  expect_failures = [var.name_prefix]
}

# U-03
run "custom_tags_are_merged" {
  command = plan

  variables {
    advanced_settings = {
      tags = {
        Owner = "tester"
      }
    }
  }

  assert {
    condition     = local.tags["Owner"] == "tester" && local.tags["ManagedBy"] == "opentofu"
    error_message = "Custom tags are not merged with the default tags."
  }
}

# U-04
run "public_blob_access_is_disabled" {
  command = apply

  assert {
    condition     = !azurerm_storage_account.site.allow_nested_items_to_be_public
    error_message = "Anonymous access to blob containers must be disabled."
  }
}

# U-05
run "https_and_tls_1_2_are_enforced" {
  command = apply

  assert {
    condition     = azurerm_storage_account.site.https_traffic_only_enabled && azurerm_storage_account.site.min_tls_version == "TLS1_2"
    error_message = "The storage account must allow HTTPS only with TLS 1.2 or higher."
  }
}

# U-06
run "encryption_and_recovery_are_enabled" {
  command = apply

  assert {
    condition     = azurerm_storage_account.site.infrastructure_encryption_enabled
    error_message = "Infrastructure (double) encryption must be enabled."
  }

  assert {
    condition = (
      one(azurerm_storage_account.site.blob_properties).versioning_enabled &&
      one(one(azurerm_storage_account.site.blob_properties).delete_retention_policy).days >= 7
    )
    error_message = "Blob versioning and soft delete must be enabled."
  }
}

# U-07
run "static_website_is_configured" {
  command = apply

  assert {
    condition     = azurerm_storage_account_static_website.site.index_document == "index.html" && azurerm_storage_account_static_website.site.error_404_document == "404.html"
    error_message = "Static website must serve index.html and 404.html."
  }

  assert {
    condition     = alltrue([for b in azurerm_storage_blob.pages : endswith(b.storage_container_id, "/containers/$web") && startswith(b.content_type, "text/html")])
    error_message = "Pages must be uploaded to the $web container as text/html."
  }

  assert {
    condition     = output.website_url == "https://mocksite.z6.web.core.windows.net"
    error_message = "The website URL must be the HTTPS static website endpoint."
  }
}

# U-08
run "access_logs_are_enabled" {
  command = apply

  assert {
    condition = (
      endswith(azurerm_monitor_diagnostic_setting.blob.target_resource_id, "/blobServices/default") &&
      contains([for l in azurerm_monitor_diagnostic_setting.blob.enabled_log : l.category], "StorageRead")
    )
    error_message = "Read access logs of the blob service must be sent to Log Analytics."
  }
}
