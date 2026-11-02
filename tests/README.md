# Tests

Tests use the built-in OpenTofu test framework (`tofu test`, OpenTofu 1.8 or later).

| Level | Folder | What it does | Cost | When it runs |
|---|---|---|---|---|
| Unit | `tests/unit` | Plan only with mocked providers. Checks configuration and security settings. | None | Every push and pull request |
| Integration | `tests/integration` | Deploys real resources, checks them, destroys them. | Cloud cost while running | Manually (GitHub Actions `integration` workflow) |

## Run locally

```bash
tofu init
tofu test -test-directory=tests/unit
tofu test -test-directory=tests/integration   # needs cloud credentials
```

## Test cases

| ID | Level | Description | Status |
|---|---|---|---|
| U-01 | Unit | Default variables produce a valid plan with all default tags | done |
| U-02 | Unit | Invalid `name_prefix` is rejected | done |
| U-03 | Unit | Custom `tags` are merged with the default tags | done |
| U-04 | Unit | Anonymous blob container access is disabled | done |
| U-05 | Unit | HTTPS only with TLS 1.2 or higher | done |
| U-06 | Unit | Infrastructure encryption, blob versioning and soft delete are enabled | done |
| U-07 | Unit | Static website serves `index.html` and `404.html`, pages are in `$web` as `text/html`, URL is the HTTPS endpoint | done |
| U-08 | Unit | Access logs of the blob service go to Log Analytics | done |
| I-01 | Integration | HTTPS GET on the website URL returns 200 and the sample page | done |
| I-02 | Integration | Plain HTTP request is rejected | done |
| I-03 | Integration | Anonymous request through the blob endpoint is denied | done |

Integration tests are written but have not run against a real cloud account yet.
