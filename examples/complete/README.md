# complete

Deploys an Azure OpenAI Cognitive Services account (`kind = OpenAI`, SKU `S0`) using this primitive, with a Launch resource group and resource naming modules. No Provisioned Throughput (PTU) SKUs are used.

## Usage

```hcl
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
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.117, < 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cognitive_account"></a> [cognitive\_account](#module\_cognitive\_account) | ../.. | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class used for resource naming. | `string` | `"dev"` | no |
| <a name="input_custom_question_answering_search_service_id"></a> [custom\_question\_answering\_search\_service\_id](#input\_custom\_question\_answering\_search\_service\_id) | Passed through to the module. | `string` | `null` | no |
| <a name="input_custom_question_answering_search_service_key"></a> [custom\_question\_answering\_search\_service\_key](#input\_custom\_question\_answering\_search\_service\_key) | Passed through to the module. | `string` | `null` | no |
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | Optional override for the custom subdomain. Null derives one from the naming module. | `string` | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Passed through to the module. | <pre>object({<br/>    key_vault_key_id   = string<br/>    identity_client_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_dynamic_throttling_enabled"></a> [dynamic\_throttling\_enabled](#input\_dynamic\_throttling\_enabled) | Passed through to the module. Leave null for OpenAI (unsupported). | `bool` | `null` | no |
| <a name="input_fqdns"></a> [fqdns](#input\_fqdns) | Passed through to the module. | `list(string)` | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Passed through to the module. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Numeric environment instance used for resource naming. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Numeric resource instance used for resource naming. | `number` | `0` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Cognitive Services account kind passed to the module. | `string` | `"OpenAI"` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Passed through to the module. | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which to deploy the example. | `string` | `"eastus"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family used for resource naming. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service used for resource naming. | `string` | `"cogacct"` | no |
| <a name="input_metrics_advisor_aad_client_id"></a> [metrics\_advisor\_aad\_client\_id](#input\_metrics\_advisor\_aad\_client\_id) | Passed through to the module. | `string` | `null` | no |
| <a name="input_metrics_advisor_aad_tenant_id"></a> [metrics\_advisor\_aad\_tenant\_id](#input\_metrics\_advisor\_aad\_tenant\_id) | Passed through to the module. | `string` | `null` | no |
| <a name="input_metrics_advisor_super_user_name"></a> [metrics\_advisor\_super\_user\_name](#input\_metrics\_advisor\_super\_user\_name) | Passed through to the module. | `string` | `null` | no |
| <a name="input_metrics_advisor_website_name"></a> [metrics\_advisor\_website\_name](#input\_metrics\_advisor\_website\_name) | Passed through to the module. | `string` | `null` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Passed through to the module. | <pre>object({<br/>    default_action = string<br/>    bypass         = optional(string)<br/>    ip_rules       = optional(list(string))<br/>    virtual_network_rules = optional(list(object({<br/>      subnet_id                            = string<br/>      ignore_missing_vnet_service_endpoint = optional(bool)<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_network_injection"></a> [network\_injection](#input\_network\_injection) | Passed through to the module. | <pre>object({<br/>    scenario  = string<br/>    subnet_id = string<br/>  })</pre> | `null` | no |
| <a name="input_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#input\_outbound\_network\_access\_restricted) | Passed through to the module. | `bool` | `null` | no |
| <a name="input_project_management_enabled"></a> [project\_management\_enabled](#input\_project\_management\_enabled) | Passed through to the module. | `bool` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Passed through to the module. | `bool` | `true` | no |
| <a name="input_qna_runtime_endpoint"></a> [qna\_runtime\_endpoint](#input\_qna\_runtime\_endpoint) | Passed through to the module. | `string` | `null` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource naming keys to cloud abbreviations and maximum lengths. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Cognitive Services account SKU passed to the module. Example uses Standard S0 (not PTU). | `string` | `"S0"` | no |
| <a name="input_storage"></a> [storage](#input\_storage) | Passed through to the module. | <pre>list(object({<br/>    storage_account_id = string<br/>    identity_client_id = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to example resources that support tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_subdomain_name"></a> [custom\_subdomain\_name](#output\_custom\_subdomain\_name) | Custom subdomain of the Cognitive Services account. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Endpoint URL of the Cognitive Services account. |
| <a name="output_id"></a> [id](#output\_id) | Azure resource ID of the Cognitive Services account. |
| <a name="output_kind"></a> [kind](#output\_kind) | Kind of the Cognitive Services account. |
| <a name="output_location"></a> [location](#output\_location) | Azure region of the Cognitive Services account. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Cognitive Services account. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the example resource group. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | SKU name of the Cognitive Services account. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags on the Cognitive Services account. |
<!-- END_TF_DOCS -->
