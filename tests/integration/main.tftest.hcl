# Integration tests: deploy real resources, check them, then destroy them.
# This costs money and needs cloud credentials.
# Run: tofu test -test-directory=tests/integration
# Test case catalog: tests/README.md

variables {
  name_prefix = "itest"
  advanced_settings = {
    tags = {
      Purpose = "integration-test"
    }
  }
}

run "deploy" {
  command = apply
}

# I-01
run "website_is_served" {
  module {
    source = "./tests/integration/http-check"
  }

  variables {
    url = run.deploy.website_url
  }

  assert {
    condition     = output.status_code == 200 && strcontains(output.body, "demo-marker: static-website-ok")
    error_message = "The website did not return the sample page."
  }
}

# I-02
run "plain_http_is_rejected" {
  module {
    source = "./tests/integration/http-check"
  }

  variables {
    url = replace(run.deploy.website_url, "https://", "http://")
  }

  assert {
    condition     = output.status_code != 200
    error_message = "Plain HTTP requests must be rejected."
  }
}

# I-03
run "anonymous_blob_access_is_denied" {
  module {
    source = "./tests/integration/http-check"
  }

  variables {
    url = "${run.deploy.blob_endpoint}$web/index.html"
  }

  assert {
    condition     = output.status_code != 200
    error_message = "Anonymous access through the blob endpoint must be denied."
  }
}
