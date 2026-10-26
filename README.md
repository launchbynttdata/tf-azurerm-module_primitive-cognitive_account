# Azure Cognitive Account Primitive

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

Thin Launch Terraform primitive wrapping a single `azurerm_cognitive_account` resource. Use it for Azure OpenAI and other Cognitive Services account kinds. The public contract exposes non-secret outputs (`id`, `name`, `endpoint`, and related attributes) and does **not** export API keys.

The complete example uses `kind = "OpenAI"` with Standard SKU `S0` and does not introduce Provisioned Throughput (PTU) SKUs.

Until a release is published to the Launch registry, consumers can pin this branch:

```hcl
module "cognitive_account" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-cognitive_account.git?ref=feat/initial-module"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"
  custom_subdomain_name = var.custom_subdomain_name
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.47.0, < 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cognitive_account.cognitive_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_question_answering_search_service_id"></a> [custom\_question\_answering\_search\_service\_id](#input\_custom\_question\_answering\_search\_service\_id) | Azure AI Search service ID for Custom Question Answering when kind is TextAnalytics. | `string` | `null` | no |
| <a name="input_custom_question_answering_search_service_key"></a> [custom\_question\_answering\_search\_service\_key](#input\_custom\_question\_answering\_search\_service\_key) | Azure AI Search service key for Custom Question Answering when kind is TextAnalytics. | `string` | `null` | no |
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | Custom subdomain for Entra ID token-based authentication and Azure OpenAI-style endpoints. Required when network\_acls is set. Once set, changing this forces a new resource. | `string` | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer-managed key encryption. key\_vault\_key\_id is required; identity\_client\_id is optional when multiple identities are attached. | <pre>object({<br/>    key_vault_key_id   = string<br/>    identity_client_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_dynamic_throttling_enabled"></a> [dynamic\_throttling\_enabled](#input\_dynamic\_throttling\_enabled) | Whether dynamic throttling is enabled. Cannot be set when kind is OpenAI or AIServices. | `bool` | `null` | no |
| <a name="input_fqdns"></a> [fqdns](#input\_fqdns) | List of FQDNs allowed for the Cognitive Account. | `list(string)` | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity. type is SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Cognitive Services account kind. Common values include OpenAI and AIServices. Changing this forces a new resource except OpenAI ↔ AIServices upgrade/rollback. | `string` | n/a | yes |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether local authentication methods (API keys) are enabled. Defaults to the provider default (true) when null. | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region of the Cognitive Services account. Changing this forces a new resource. | `string` | n/a | yes |
| <a name="input_metrics_advisor_aad_client_id"></a> [metrics\_advisor\_aad\_client\_id](#input\_metrics\_advisor\_aad\_client\_id) | Azure AD application (client) ID. Only for kind MetricsAdvisor. Changing this forces a new resource. | `string` | `null` | no |
| <a name="input_metrics_advisor_aad_tenant_id"></a> [metrics\_advisor\_aad\_tenant\_id](#input\_metrics\_advisor\_aad\_tenant\_id) | Azure AD tenant ID. Only for kind MetricsAdvisor. Changing this forces a new resource. | `string` | `null` | no |
| <a name="input_metrics_advisor_super_user_name"></a> [metrics\_advisor\_super\_user\_name](#input\_metrics\_advisor\_super\_user\_name) | Metrics Advisor super user. Only for kind MetricsAdvisor. Changing this forces a new resource. | `string` | `null` | no |
| <a name="input_metrics_advisor_website_name"></a> [metrics\_advisor\_website\_name](#input\_metrics\_advisor\_website\_name) | Metrics Advisor website name. Only for kind MetricsAdvisor. Changing this forces a new resource. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Cognitive Services account. Must be 2-64 characters, alphanumeric and hyphens only, and start and end with an alphanumeric character. Changing this forces a new resource. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network ACL configuration. When set, custom\_subdomain\_name is required. bypass may be None or AzureServices (OpenAI, AIServices, or TextAnalytics only). | <pre>object({<br/>    default_action = string<br/>    bypass         = optional(string)<br/>    ip_rules       = optional(list(string))<br/>    virtual_network_rules = optional(list(object({<br/>      subnet_id                            = string<br/>      ignore_missing_vnet_service_endpoint = optional(bool)<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_network_injection"></a> [network\_injection](#input\_network\_injection) | Network injection for AIServices agent features. scenario must be agent. | <pre>object({<br/>    scenario  = string<br/>    subnet_id = string<br/>  })</pre> | `null` | no |
| <a name="input_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#input\_outbound\_network\_access\_restricted) | Whether outbound network access is restricted. Defaults to the provider default (false) when null. | `bool` | `null` | no |
| <a name="input_project_management_enabled"></a> [project\_management\_enabled](#input\_project\_management\_enabled) | Whether project management is enabled. Can only be true when kind is AIServices. | `bool` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed. Defaults to the provider default (true) when null. | `bool` | `null` | no |
| <a name="input_qna_runtime_endpoint"></a> [qna\_runtime\_endpoint](#input\_qna\_runtime\_endpoint) | QnA Maker runtime endpoint URL. Required when kind is QnAMaker. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group containing the Cognitive Services account. Changing this forces a new resource. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the Cognitive Services account. Use Standard-class SKUs such as S0 for OpenAI; do not use Provisioned Throughput (PTU) SKUs here. | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Storage accounts associated with the Cognitive Account. Not supported for all kinds (for example OpenAI). | <pre>list(object({<br/>    storage_account_id = string<br/>    identity_client_id = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags assigned to the Cognitive Services account. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_subdomain_name"></a> [custom\_subdomain\_name](#output\_custom\_subdomain\_name) | Custom subdomain configured on the Cognitive Services account. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Endpoint URL used to connect to the Cognitive Services account. |
| <a name="output_id"></a> [id](#output\_id) | Azure resource ID of the Cognitive Services account. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity block on the Cognitive Services account. |
| <a name="output_kind"></a> [kind](#output\_kind) | Kind of the Cognitive Services account. |
| <a name="output_location"></a> [location](#output\_location) | Azure region of the Cognitive Services account. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Cognitive Services account. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group of the Cognitive Services account. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | SKU name of the Cognitive Services account. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags assigned to the Cognitive Services account. |
<!-- END_TF_DOCS -->

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider (e.g. AWS or Azure) for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default (main) branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge. A breaking change will trigger a major version bump, a feature will trigger a minor version bump, and all other types will trigger a patch version bump.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules (e.g. Lambda functions), there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.
