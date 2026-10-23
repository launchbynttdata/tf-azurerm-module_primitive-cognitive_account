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

package testimpl

import (
	"os"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/to"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/cognitiveservices/armcognitiveservices"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	expectedKind     = "OpenAI"
	expectedSKU      = "S0"
	functionalTagKey = "terratest_mutation"
	functionalTagVal = "updated"
)

type accountTestContext struct {
	client            *armcognitiveservices.AccountsClient
	resourceGroupName string
	accountName       string
	resourceID        string
	endpoint          string
	customSubdomain   string
	originalTags      map[string]string
}

func newAccountTestContext(t *testing.T, ctx types.TestContext) accountTestContext {
	t.Helper()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID must be set")

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "create Azure credential")

	client, err := armcognitiveservices.NewAccountsClient(subscriptionID, credential, &arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{Cloud: cloud.AzurePublic},
	})
	require.NoError(t, err, "create Cognitive Services accounts client")

	tfOptions := ctx.TerratestTerraformOptions()
	outputContext := t.Context()

	return accountTestContext{
		client:            client,
		resourceGroupName: terraform.OutputContext(t, outputContext, tfOptions, "resource_group_name"),
		accountName:       terraform.OutputContext(t, outputContext, tfOptions, "name"),
		resourceID:        terraform.OutputContext(t, outputContext, tfOptions, "id"),
		endpoint:          terraform.OutputContext(t, outputContext, tfOptions, "endpoint"),
		customSubdomain:   terraform.OutputContext(t, outputContext, tfOptions, "custom_subdomain_name"),
		originalTags:      terraform.OutputMapContext(t, outputContext, tfOptions, "tags"),
	}
}

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	assertPostApplyPlanEmpty(t, ctx)

	testCtx := newAccountTestContext(t, ctx)
	assertConfiguredAccount(t, ctx, testCtx)

	updateTags(t, testCtx, mergeTag(testCtx.originalTags, functionalTagKey, functionalTagVal))
	defer updateTags(t, testCtx, testCtx.originalTags)

	account := getAccount(t, testCtx)
	require.NotNil(t, account.Tags)
	require.Contains(t, account.Tags, functionalTagKey)
	require.NotNil(t, account.Tags[functionalTagKey])
	assert.Equal(t, functionalTagVal, *account.Tags[functionalTagKey])
}

func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	testCtx := newAccountTestContext(t, ctx)
	assertConfiguredAccount(t, ctx, testCtx)
}

func assertConfiguredAccount(t *testing.T, ctx types.TestContext, testCtx accountTestContext) {
	t.Helper()

	account := getAccount(t, testCtx)

	require.NotNil(t, account.ID)
	assert.True(t, strings.EqualFold(testCtx.resourceID, *account.ID), "resource ID mismatch: terraform=%s api=%s", testCtx.resourceID, *account.ID)
	require.NotNil(t, account.Name)
	assert.Equal(t, testCtx.accountName, *account.Name)

	require.NotNil(t, account.Kind)
	assert.Equal(t, expectedKind, *account.Kind)
	require.NotNil(t, account.SKU)
	require.NotNil(t, account.SKU.Name)
	assert.Equal(t, expectedSKU, *account.SKU.Name)

	require.NotNil(t, account.Properties)
	require.NotNil(t, account.Properties.Endpoint)
	assert.Equal(t, testCtx.endpoint, *account.Properties.Endpoint)
	require.NotNil(t, account.Properties.CustomSubDomainName)
	assert.Equal(t, testCtx.customSubdomain, *account.Properties.CustomSubDomainName)

	tfOptions := ctx.TerratestTerraformOptions()
	outputContext := t.Context()
	assert.Equal(t, expectedKind, terraform.OutputContext(t, outputContext, tfOptions, "kind"))
	assert.Equal(t, expectedSKU, terraform.OutputContext(t, outputContext, tfOptions, "sku_name"))
}

func assertPostApplyPlanEmpty(t *testing.T, ctx types.TestContext) {
	t.Helper()

	out, err := terraform.PlanContextE(t, t.Context(), ctx.TerratestTerraformOptions())
	require.NoError(t, err, "post-apply terraform plan")
	t.Logf("post-apply terraform plan:\n%s", out)
	if !strings.Contains(out, "No changes") {
		t.Fatalf("terraform configuration not idempotent\n%s", out)
	}
}

func getAccount(t *testing.T, testCtx accountTestContext) armcognitiveservices.AccountsClientGetResponse {
	t.Helper()

	account, err := testCtx.client.Get(t.Context(), testCtx.resourceGroupName, testCtx.accountName, nil)
	require.NoError(t, err, "get Cognitive Services account")
	return account
}

func updateTags(t *testing.T, testCtx accountTestContext, tags map[string]string) {
	t.Helper()

	sdkTags := make(map[string]*string, len(tags))
	for key, value := range tags {
		sdkTags[key] = to.Ptr(value)
	}

	poller, err := testCtx.client.BeginUpdate(t.Context(), testCtx.resourceGroupName, testCtx.accountName, armcognitiveservices.Account{
		Tags: sdkTags,
	}, nil)
	require.NoError(t, err, "begin update Cognitive Services account tags")

	_, err = poller.PollUntilDone(t.Context(), nil)
	require.NoError(t, err, "complete update Cognitive Services account tags")
}

func mergeTag(base map[string]string, key, value string) map[string]string {
	merged := make(map[string]string, len(base)+1)
	for k, v := range base {
		merged[k] = v
	}
	merged[key] = value
	return merged
}
