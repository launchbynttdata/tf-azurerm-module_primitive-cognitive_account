# Plan-only validation coverage for root variable rules.
# Run with: terraform test (or make check). PR CI does not run this yet.

mock_provider "azurerm" {}

variables {
  name                = "oai-example01"
  location            = "eastus"
  resource_group_name = "rg-example"
  kind                = "OpenAI"
  sku_name            = "S0"
}

run "required_inputs_only" {
  command = plan
}

run "name_valid" {
  command = plan

  variables {
    name = "OpenAI-Account1"
  }
}

run "name_too_short" {
  command = plan

  variables {
    name = "a"
  }

  expect_failures = [var.name]
}

run "name_too_long" {
  command = plan

  variables {
    # 65-character alphanumeric name (one over the 64-char max).
    name = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" # pragma: allowlist secret
  }

  expect_failures = [var.name]
}

run "name_starts_with_hyphen" {
  command = plan

  variables {
    name = "-openai"
  }

  expect_failures = [var.name]
}

run "name_ends_with_hyphen" {
  command = plan

  variables {
    name = "openai-"
  }

  expect_failures = [var.name]
}

run "name_disallowed_underscore" {
  command = plan

  variables {
    name = "open_ai"
  }

  expect_failures = [var.name]
}

run "kind_invalid" {
  command = plan

  variables {
    kind = "NotARealKind"
  }

  expect_failures = [var.kind]
}

run "sku_invalid" {
  command = plan

  variables {
    sku_name = "PTU"
  }

  expect_failures = [var.sku_name]
}

run "identity_type_invalid" {
  command = plan

  variables {
    identity = {
      type = "None"
    }
  }

  expect_failures = [var.identity]
}

run "network_acls_requires_custom_subdomain" {
  command = plan

  variables {
    network_acls = {
      default_action = "Deny"
    }
  }

  expect_failures = [azurerm_cognitive_account.cognitive_account]
}
