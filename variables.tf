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

variable "name" {
  description = "Name of the Cognitive Services account. Must be 2-64 characters, alphanumeric and hyphens only, and start and end with an alphanumeric character. Changing this forces a new resource."
  type        = string

  validation {
    condition = (
      length(var.name) >= 2 &&
      length(var.name) <= 64 &&
      can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.name))
    )
    error_message = "name must be 2-64 characters, use only alphanumerics and hyphens, and start and end with an alphanumeric character."
  }
}

variable "location" {
  description = "Azure region of the Cognitive Services account. Changing this forces a new resource."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the Cognitive Services account. Changing this forces a new resource."
  type        = string
}

variable "kind" {
  description = "Cognitive Services account kind. Common values include OpenAI and AIServices. Changing this forces a new resource except OpenAI ↔ AIServices upgrade/rollback."
  type        = string

  validation {
    condition = contains([
      "Academic",
      "AIServices",
      "AnomalyDetector",
      "Bing.Autosuggest",
      "Bing.Autosuggest.v7",
      "Bing.CustomSearch",
      "Bing.Search",
      "Bing.Search.v7",
      "Bing.Speech",
      "Bing.SpellCheck",
      "Bing.SpellCheck.v7",
      "CognitiveServices",
      "ComputerVision",
      "ContentModerator",
      "ContentSafety",
      "CustomSpeech",
      "CustomVision.Prediction",
      "CustomVision.Training",
      "Emotion",
      "Face",
      "FormRecognizer",
      "ImmersiveReader",
      "LUIS",
      "LUIS.Authoring",
      "MetricsAdvisor",
      "OpenAI",
      "Personalizer",
      "QnAMaker",
      "Recommendations",
      "SpeakerRecognition",
      "Speech",
      "SpeechServices",
      "SpeechTranslation",
      "TextAnalytics",
      "TextTranslation",
      "WebLM",
    ], var.kind)
    error_message = "kind must be a supported Cognitive Services account kind (for example OpenAI or AIServices)."
  }
}

variable "sku_name" {
  description = "SKU name for the Cognitive Services account. Use Standard-class SKUs such as S0 for OpenAI; do not use Provisioned Throughput (PTU) SKUs here."
  type        = string

  validation {
    condition = contains([
      "C2", "C3", "C4", "D3", "DC0", "E0", "F0", "F1",
      "P0", "P1", "P2", "S", "S0", "S1", "S2", "S3", "S4", "S5", "S6",
    ], var.sku_name)
    error_message = "sku_name must be a supported Cognitive Services account SKU (for example S0)."
  }
}

variable "custom_subdomain_name" {
  description = "Custom subdomain for Entra ID token-based authentication and Azure OpenAI-style endpoints. Required when network_acls is set. Once set, changing this forces a new resource."
  type        = string
  default     = null

  validation {
    condition = (
      var.custom_subdomain_name == null ? true : (
        length(var.custom_subdomain_name) >= 2 &&
        length(var.custom_subdomain_name) <= 64 &&
        can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.custom_subdomain_name))
      )
    )
    error_message = "custom_subdomain_name must be 2-64 characters, use only alphanumerics and hyphens, and start and end with an alphanumeric character."
  }
}

variable "dynamic_throttling_enabled" {
  description = "Whether dynamic throttling is enabled. Cannot be set when kind is OpenAI or AIServices."
  type        = bool
  default     = null
}

variable "customer_managed_key" {
  description = "Customer-managed key encryption. key_vault_key_id is required; identity_client_id is optional when multiple identities are attached."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null
}

variable "fqdns" {
  description = "List of FQDNs allowed for the Cognitive Account."
  type        = list(string)
  default     = null
}

variable "identity" {
  description = "Managed identity. type is SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition = (
      var.identity == null ? true : contains([
        "SystemAssigned",
        "UserAssigned",
        "SystemAssigned, UserAssigned",
      ], var.identity.type)
    )
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "local_auth_enabled" {
  description = "Whether local authentication methods (API keys) are enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "metrics_advisor_aad_client_id" {
  description = "Azure AD application (client) ID. Only for kind MetricsAdvisor. Changing this forces a new resource."
  type        = string
  default     = null
}

variable "metrics_advisor_aad_tenant_id" {
  description = "Azure AD tenant ID. Only for kind MetricsAdvisor. Changing this forces a new resource."
  type        = string
  default     = null
}

variable "metrics_advisor_super_user_name" {
  description = "Metrics Advisor super user. Only for kind MetricsAdvisor. Changing this forces a new resource."
  type        = string
  default     = null
}

variable "metrics_advisor_website_name" {
  description = "Metrics Advisor website name. Only for kind MetricsAdvisor. Changing this forces a new resource."
  type        = string
  default     = null
}

variable "network_acls" {
  description = "Network ACL configuration. When set, custom_subdomain_name is required. bypass may be None or AzureServices (OpenAI, AIServices, or TextAnalytics only)."
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

  validation {
    condition = (
      var.network_acls == null ? true : contains(["Allow", "Deny"], var.network_acls.default_action)
    )
    error_message = "network_acls.default_action must be Allow or Deny."
  }

  validation {
    condition = (
      var.network_acls == null ? true : (
        try(var.network_acls.bypass, null) == null ? true : contains(["None", "AzureServices"], var.network_acls.bypass)
      )
    )
    error_message = "network_acls.bypass must be None or AzureServices when set."
  }
}

variable "network_injection" {
  description = "Network injection for AIServices agent features. scenario must be agent."
  type = object({
    scenario  = string
    subnet_id = string
  })
  default = null

  validation {
    condition = (
      var.network_injection == null ? true : var.network_injection.scenario == "agent"
    )
    error_message = "network_injection.scenario must be agent."
  }
}

variable "outbound_network_access_restricted" {
  description = "Whether outbound network access is restricted. Defaults to the provider default (false) when null."
  type        = bool
  default     = null
}

variable "project_management_enabled" {
  description = "Whether project management is enabled. Can only be true when kind is AIServices."
  type        = bool
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed. Defaults to false."
  type        = bool
  default     = false
}

variable "qna_runtime_endpoint" {
  description = "QnA Maker runtime endpoint URL. Required when kind is QnAMaker."
  type        = string
  default     = null
}

variable "custom_question_answering_search_service_id" {
  description = "Azure AI Search service ID for Custom Question Answering when kind is TextAnalytics."
  type        = string
  default     = null
}

variable "custom_question_answering_search_service_key" {
  description = "Azure AI Search service key for Custom Question Answering when kind is TextAnalytics."
  type        = string
  default     = null
  sensitive   = true
}

variable "storage" {
  description = "Storage accounts associated with the Cognitive Account. Not supported for all kinds (for example OpenAI)."
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default = null
}

variable "tags" {
  description = "Tags assigned to the Cognitive Services account."
  type        = map(string)
  default     = {}
}
