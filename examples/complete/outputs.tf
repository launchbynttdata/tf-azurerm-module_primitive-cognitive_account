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

output "id" {
  description = "Azure resource ID of the Cognitive Services account."
  value       = module.cognitive_account.id
}

output "name" {
  description = "Name of the Cognitive Services account."
  value       = module.cognitive_account.name
}

output "endpoint" {
  description = "Endpoint URL of the Cognitive Services account."
  value       = module.cognitive_account.endpoint
}

output "resource_group_name" {
  description = "Name of the example resource group."
  value       = module.resource_group.name
}

output "kind" {
  description = "Kind of the Cognitive Services account."
  value       = module.cognitive_account.kind
}

output "sku_name" {
  description = "SKU name of the Cognitive Services account."
  value       = module.cognitive_account.sku_name
}

output "custom_subdomain_name" {
  description = "Custom subdomain of the Cognitive Services account."
  value       = module.cognitive_account.custom_subdomain_name
}

output "location" {
  description = "Azure region of the Cognitive Services account."
  value       = module.cognitive_account.location
}

output "tags" {
  description = "Tags on the Cognitive Services account."
  value       = module.cognitive_account.tags
}
