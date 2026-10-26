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

terraform {
  # object(optional()) variables and validation.tftest.hcl mock_provider need Terraform >= 1.7.
  required_version = "~> 1.7"

  required_providers {
    # project_management_enabled, network_acls.bypass, and network_injection require AzureRM >= 4.47.0.
    # Keep < 5.0 until examples/complete is validated on 5.x.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.47.0, < 5.0"
    }
  }
}
