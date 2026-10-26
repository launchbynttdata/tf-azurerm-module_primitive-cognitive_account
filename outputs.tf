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
  value       = azurerm_cognitive_account.cognitive_account.id
}

output "name" {
  description = "Name of the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.name
}

output "endpoint" {
  description = "Endpoint URL used to connect to the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.endpoint
}

output "location" {
  description = "Azure region of the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.location
}

output "resource_group_name" {
  description = "Resource group of the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.resource_group_name
}

output "kind" {
  description = "Kind of the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.kind
}

output "sku_name" {
  description = "SKU name of the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.sku_name
}

output "custom_subdomain_name" {
  description = "Custom subdomain configured on the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.custom_subdomain_name
}

output "identity" {
  description = "Managed identity block on the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.identity
}

output "tags" {
  description = "Tags assigned to the Cognitive Services account."
  value       = azurerm_cognitive_account.cognitive_account.tags
}
