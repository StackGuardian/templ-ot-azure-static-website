# Azure Static Website (Storage Account)

Publishes a static website directly from an Azure storage account. The template ships two sample pages (`index.html` and `404.html`), so you get a working site right after the first run.

Use it for a simple, low-cost website on Azure. It has no CDN.

## What gets created

- A resource group
- A storage account with static website hosting and the sample pages
- A Log Analytics workspace with the access logs

## Before you start

- A workflow with an Azure cloud connector for the target subscription
- Permissions to create resource groups, storage accounts and Log Analytics workspaces

## Form fields

| Field | What it does | Default |
|---|---|---|
| Name prefix | Prefix for all resource names. 2 to 16 lowercase letters, digits or hyphens, starting with a letter | `demo` |
| Location | Azure region | Germany West Central |

**Advanced Settings** (tick "Show advanced settings" to change them):

| Field | What it does | Default |
|---|---|---|
| Log retention days | How long access logs are kept, 30 to 730 days | `90` |
| Tags | Extra tags added to all resources | none |

For a quick demo, keep all defaults.

## After the run

The workflow outputs show:

- `website_url`: open it in a browser to see the site
- `storage_account_name` and `resource_group_name`

## Security defaults

- HTTPS only, TLS 1.2 minimum
- Only the website files are public, read-only. Anonymous access to other blobs is disabled
- Double encryption at rest, file versioning and soft delete for 7 days
- Access logs go to Log Analytics

## Cost and cleanup

Costs are low for demo traffic. Storage, transactions and log ingestion are billed by usage. Destroy the resources from the workflow when the demo is over.

## Limits

- No CDN: no caching, no WAF and no custom domain with HTTPS
- The site uses the Microsoft address `*.web.core.windows.net`
