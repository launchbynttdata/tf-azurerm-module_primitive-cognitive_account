// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

resource "azurerm_cognitive_account" "cognitive_account" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.kind
  sku_name            = var.sku_name

  custom_subdomain_name                        = var.custom_subdomain_name
  dynamic_throttling_enabled                   = var.dynamic_throttling_enabled
  fqdns                                        = var.fqdns
  local_auth_enabled                           = var.local_auth_enabled
  metrics_advisor_aad_client_id                = var.metrics_advisor_aad_client_id
  metrics_advisor_aad_tenant_id                = var.metrics_advisor_aad_tenant_id
  metrics_advisor_super_user_name              = var.metrics_advisor_super_user_name
  metrics_advisor_website_name                 = var.metrics_advisor_website_name
  outbound_network_access_restricted           = var.outbound_network_access_restricted
  project_management_enabled                   = var.project_management_enabled
  public_network_access_enabled                = var.public_network_access_enabled
  qna_runtime_endpoint                         = var.qna_runtime_endpoint
  custom_question_answering_search_service_id  = var.custom_question_answering_search_service_id
  custom_question_answering_search_service_key = var.custom_question_answering_search_service_key

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [var.customer_managed_key]
    content {
      key_vault_key_id   = customer_managed_key.value.key_vault_key_id
      identity_client_id = customer_managed_key.value.identity_client_id
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    content {
      default_action = network_acls.value.default_action
      bypass         = network_acls.value.bypass
      ip_rules       = network_acls.value.ip_rules

      dynamic "virtual_network_rules" {
        for_each = network_acls.value.virtual_network_rules == null ? [] : network_acls.value.virtual_network_rules
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  dynamic "network_injection" {
    for_each = var.network_injection == null ? [] : [var.network_injection]
    content {
      scenario  = network_injection.value.scenario
      subnet_id = network_injection.value.subnet_id
    }
  }

  dynamic "storage" {
    for_each = var.storage == null ? [] : var.storage
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = storage.value.identity_client_id
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.network_acls == null || var.custom_subdomain_name != null
      error_message = "custom_subdomain_name must be set when network_acls is configured."
    }

    precondition {
      condition     = var.local_auth_enabled || var.custom_subdomain_name != null
      error_message = "custom_subdomain_name must be set when local_auth_enabled is false."
    }
  }
}
