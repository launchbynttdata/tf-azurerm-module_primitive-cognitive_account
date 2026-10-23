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

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = true
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.location

  tags = merge(var.tags, {
    resource_name = module.resource_names["resource_group"].standard
  })
}

locals {
  # Cognitive account names and custom subdomains allow hyphens, not underscores.
  cognitive_account_name = lower(replace(module.resource_names["cognitive_account"].minimal_random_suffix, "_", "-"))
  custom_subdomain_name  = coalesce(var.custom_subdomain_name, local.cognitive_account_name)
}

module "cognitive_account" {
  source = "../.."

  name                = local.cognitive_account_name
  location            = var.location
  resource_group_name = module.resource_group.name
  kind                = var.kind
  sku_name            = var.sku_name

  custom_subdomain_name                        = local.custom_subdomain_name
  dynamic_throttling_enabled                   = var.dynamic_throttling_enabled
  customer_managed_key                         = var.customer_managed_key
  fqdns                                        = var.fqdns
  identity                                     = var.identity
  local_auth_enabled                           = var.local_auth_enabled
  metrics_advisor_aad_client_id                = var.metrics_advisor_aad_client_id
  metrics_advisor_aad_tenant_id                = var.metrics_advisor_aad_tenant_id
  metrics_advisor_super_user_name              = var.metrics_advisor_super_user_name
  metrics_advisor_website_name                 = var.metrics_advisor_website_name
  network_acls                                 = var.network_acls
  network_injection                            = var.network_injection
  outbound_network_access_restricted           = var.outbound_network_access_restricted
  project_management_enabled                   = var.project_management_enabled
  public_network_access_enabled                = var.public_network_access_enabled
  qna_runtime_endpoint                         = var.qna_runtime_endpoint
  custom_question_answering_search_service_id  = var.custom_question_answering_search_service_id
  custom_question_answering_search_service_key = var.custom_question_answering_search_service_key
  storage                                      = var.storage

  tags = var.tags

  depends_on = [module.resource_group]
}
