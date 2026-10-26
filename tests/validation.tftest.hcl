# Plan-only validation coverage for root variable rules.
# Run with: terraform test (or make check). PR CI does not run this yet.

mock_provider "azurerm" {}

variables {
  name                  = "oai-example01"
  location              = "eastus"
  resource_group_name   = "rg-example"
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "oai-example01"
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
    custom_subdomain_name = null
    network_acls = {
      default_action = "Deny"
    }
  }

  expect_failures = [azurerm_cognitive_account.cognitive_account]
}

run "local_auth_disabled_requires_custom_subdomain" {
  command = plan

  variables {
    custom_subdomain_name = null
    local_auth_enabled    = false
  }

  expect_failures = [azurerm_cognitive_account.cognitive_account]
}

run "local_auth_enabled_without_custom_subdomain_valid" {
  command = plan

  variables {
    custom_subdomain_name = null
    local_auth_enabled    = true
  }
}

run "custom_subdomain_name_valid" {
  command = plan

  variables {
    custom_subdomain_name = "oai-example01"
  }
}

run "custom_subdomain_name_invalid" {
  command = plan

  variables {
    custom_subdomain_name = "-bad-subdomain"
  }

  expect_failures = [var.custom_subdomain_name]
}

run "identity_system_assigned_valid" {
  command = plan

  variables {
    identity = {
      type = "SystemAssigned"
    }
  }
}

run "identity_user_assigned_valid" {
  command = plan

  variables {
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-example"]
    }
  }
}

run "network_acls_valid" {
  command = plan

  variables {
    custom_subdomain_name = "oai-example01"

    network_acls = {
      default_action = "Deny"
      bypass         = "AzureServices"
      ip_rules       = ["203.0.113.10"]
      virtual_network_rules = [
        {
          subnet_id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-example"
          ignore_missing_vnet_service_endpoint = true
        }
      ]
    }
  }
}

run "network_acls_default_action_invalid" {
  command = plan

  variables {
    custom_subdomain_name = "oai-example01"

    network_acls = {
      default_action = "Block"
    }
  }

  expect_failures = [var.network_acls]
}

run "network_acls_bypass_invalid" {
  command = plan

  variables {
    custom_subdomain_name = "oai-example01"

    network_acls = {
      default_action = "Deny"
      bypass         = "Everything"
    }
  }

  expect_failures = [var.network_acls]
}

run "network_injection_valid" {
  command = plan

  variables {
    kind = "AIServices"

    network_injection = {
      scenario  = "agent"
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-agent"
    }
  }
}

run "network_injection_scenario_invalid" {
  command = plan

  variables {
    kind = "AIServices"

    network_injection = {
      scenario  = "none"
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-agent"
    }
  }

  expect_failures = [var.network_injection]
}

run "customer_managed_key_and_storage_valid" {
  command = plan

  variables {
    identity = {
      type = "SystemAssigned"
    }

    customer_managed_key = {
      key_vault_key_id = "https://kv-example.vault.azure.net/keys/key-example/00000000000000000000000000000000"
    }

    storage = [
      {
        storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Storage/storageAccounts/stexample"
      }
    ]
  }
}

run "defaults_are_secure" {
  command = plan

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.public_network_access_enabled == false
    error_message = "public_network_access_enabled must default to false."
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.local_auth_enabled == false
    error_message = "local_auth_enabled must default to false."
  }
}

# A caller (or wrapper module) passing null must not override the secure defaults.
run "null_inputs_keep_secure_defaults" {
  command = plan

  variables {
    public_network_access_enabled = null
    local_auth_enabled            = null
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.public_network_access_enabled == false
    error_message = "A null public_network_access_enabled must fall back to false, not the provider default (true)."
  }

  assert {
    condition     = azurerm_cognitive_account.cognitive_account.local_auth_enabled == false
    error_message = "A null local_auth_enabled must fall back to false, not the provider default (true)."
  }
}
