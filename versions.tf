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
  # optional() object attributes require Terraform >= 1.3.
  # validation.tftest.hcl uses mock_provider, which requires Terraform >= 1.7,
  # but that test-only requirement does not apply to module consumers.
  required_version = "~> 1.3"

  required_providers {
    # project_management_enabled, network_acls.bypass, and network_injection require AzureRM >= 4.47.0.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.47.0"
    }
  }
}
