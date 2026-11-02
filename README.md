# Azure Static Website

A static website served from the static website endpoint of an Azure storage account. No CDN.

OpenTofu demo template. Standalone, no dependency on other repos. Compatible with Terraform.

## Architecture

- Resource group
- Storage account with static website hosting and the sample pages from `site/` (`index.html`, `404.html`)
- Log Analytics workspace with access logs of the blob service

## Security

- HTTPS only, TLS 1.2 minimum (the endpoint uses the Microsoft certificate for `*.web.core.windows.net`)
- Only the `$web` container is served, read-only, through the static website endpoint. Anonymous access through the blob endpoint is disabled
- Infrastructure (double) encryption, blob versioning, soft delete for blobs and containers (7 days)
- Cross-tenant replication disabled
- Access logs (read, write, delete) sent to Log Analytics

Without a CDN there is no custom domain with HTTPS, no caching and no WAF. The storage account must allow public network access, because the website is public.

Accepted checkov findings (documented inline in the code):

| Check | Reason |
|---|---|
| CKV_AZURE_59, CKV_AZURE_35, CKV2_AZURE_33 | The static website endpoint must be reachable from the internet |
| CKV_AZURE_206 | LRS is enough for a demo website |
| CKV_AZURE_33 | Queue service is not used |
| CKV2_AZURE_1 | Microsoft-managed keys, customer-managed keys are out of scope |
| CKV2_AZURE_40, CKV2_AZURE_41 | Provider needs shared key access, SAS tokens are not used |

## Usage

Sign in with `az login` and set `ARM_SUBSCRIPTION_ID` to the target subscription.

```bash
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
tofu apply
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `name_prefix` | Prefix for all resource names | `"demo"` |
| `location` | Azure location | `"germanywestcentral"` |
| `tags` | Additional tags for all resources | `{}` |
| `log_retention_days` | Access log retention in Log Analytics | `90` |

To change the content, edit the files in `site/` and run `tofu apply`.

## Outputs

| Name | Description |
|---|---|
| `website_url` | URL of the website |
| `storage_account_name` | Name of the storage account |
| `resource_group_name` | Name of the resource group |
| `blob_endpoint` | Blob endpoint |

## Cost

Costs are low for demo traffic. Storage, transactions and Log Analytics ingestion are billed by usage.

**Destroy after the demo:**

```bash
tofu destroy
```

## Tests

Unit tests run with mocked providers on every push and pull request. Integration tests deploy real
resources and run manually through the `integration` workflow. They need the repository variables `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` and `AZURE_SUBSCRIPTION_ID` (app registration with a federated credential for GitHub OIDC).

```bash
tofu test -test-directory=tests/unit
```

Test cases: [tests/README.md](tests/README.md)

## Development

```bash
pre-commit install
pre-commit run --all-files
```
