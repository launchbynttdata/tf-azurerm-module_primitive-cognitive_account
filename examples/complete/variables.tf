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

variable "logical_product_family" {
  description = "Logical product family used for resource naming."
  type        = string
  default     = "launch"
}

variable "logical_product_service" {
  description = "Logical product service used for resource naming."
  type        = string
  default     = "cogacct"
}

variable "class_env" {
  description = "Environment class used for resource naming."
  type        = string
  default     = "dev"
}

variable "instance_env" {
  description = "Numeric environment instance used for resource naming."
  type        = number
  default     = 0
}

variable "instance_resource" {
  description = "Numeric resource instance used for resource naming."
  type        = number
  default     = 0
}

variable "location" {
  description = "Azure region in which to deploy the example."
  type        = string
  default     = "eastus"
}

variable "resource_names_map" {
  description = "Map of resource naming keys to cloud abbreviations and maximum lengths."
  type = map(object({
    name       = string
    max_length = number
  }))
}

variable "kind" {
  description = "Cognitive Services account kind passed to the module."
  type        = string
  default     = "OpenAI"
}

variable "sku_name" {
  description = "Cognitive Services account SKU passed to the module. Example uses Standard S0 (not PTU)."
  type        = string
  default     = "S0"
}

variable "custom_subdomain_name" {
  description = "Optional override for the custom subdomain. Null derives one from the naming module."
  type        = string
  default     = null
}

variable "dynamic_throttling_enabled" {
  description = "Passed through to the module. Leave null for OpenAI (unsupported)."
  type        = bool
  default     = null
}

variable "customer_managed_key" {
  description = "Passed through to the module."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null
}

variable "fqdns" {
  description = "Passed through to the module."
  type        = list(string)
  default     = null
}

variable "identity" {
  description = "Passed through to the module."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "local_auth_enabled" {
  description = "Passed through to the module."
  type        = bool
  default     = false
}

variable "metrics_advisor_aad_client_id" {
  description = "Passed through to the module."
  type        = string
  default     = null
}

variable "metrics_advisor_aad_tenant_id" {
  description = "Passed through to the module."
  type        = string
  default     = null
}

variable "metrics_advisor_super_user_name" {
  description = "Passed through to the module."
  type        = string
  default     = null
}

variable "metrics_advisor_website_name" {
  description = "Passed through to the module."
  type        = string
  default     = null
}

variable "network_acls" {
  description = "Passed through to the module."
  type = object({
    default_action = string
    bypass         = optional(string)
    ip_rules       = optional(list(string))
    virtual_network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool)
    })))
  })
  default = null
}

variable "network_injection" {
  description = "Passed through to the module."
  type = object({
    scenario  = string
    subnet_id = string
  })
  default = null
}

variable "outbound_network_access_restricted" {
  description = "Passed through to the module."
  type        = bool
  default     = null
}

variable "project_management_enabled" {
  description = "Passed through to the module."
  type        = bool
  default     = null
}

variable "public_network_access_enabled" {
  description = "Passed through to the module."
  type        = bool
  default     = false
}

variable "qna_runtime_endpoint" {
  description = "Passed through to the module."
  type        = string
  default     = null
}

variable "custom_question_answering_search_service_id" {
  description = "Passed through to the module."
  type        = string
  default     = null
}

variable "custom_question_answering_search_service_key" {
  description = "Passed through to the module."
  type        = string
  default     = null
  sensitive   = true
}

variable "storage" {
  description = "Passed through to the module."
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default = null
}

variable "tags" {
  description = "Tags to assign to example resources that support tags."
  type        = map(string)
  default     = {}
}
