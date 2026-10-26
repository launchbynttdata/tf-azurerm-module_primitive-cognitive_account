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
	"path/filepath"
	"strconv"
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
	functionalTagKey = "terratest_mutation"
	functionalTagVal = "updated"
)

// expectedSettings holds the inputs the example was applied with, read from the
// test var file so the assertions follow test.tfvars instead of duplicating it.
type expectedSettings struct {
	kind                       string
	sku                        string
	localAuthEnabled           bool
	publicNetworkAccessEnabled bool
	tags                       map[string]string
}

func loadExpectedSettings(t *testing.T, ctx types.TestContext) expectedSettings {
	t.Helper()

	tfOptions := ctx.TerratestTerraformOptions()
	require.NotEmpty(t, tfOptions.VarFiles, "terraform options must reference a var file")
	varFile := filepath.Join(tfOptions.TerraformDir, tfOptions.VarFiles[0])

	publicAccess, err := strconv.ParseBool(terraform.GetVariableAsStringFromVarFile(t, varFile, "public_network_access_enabled"))
	require.NoError(t, err, "parse public_network_access_enabled from %s", varFile)
	localAuth, err := strconv.ParseBool(terraform.GetVariableAsStringFromVarFile(t, varFile, "local_auth_enabled"))
	require.NoError(t, err, "parse local_auth_enabled from %s", varFile)

	return expectedSettings{
		kind:                       terraform.GetVariableAsStringFromVarFile(t, varFile, "kind"),
		sku:                        terraform.GetVariableAsStringFromVarFile(t, varFile, "sku_name"),
		localAuthEnabled:           localAuth,
		publicNetworkAccessEnabled: publicAccess,
		tags:                       terraform.GetVariableAsMapFromVarFile(t, varFile, "tags"),
	}
}

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

	expected := loadExpectedSettings(t, ctx)
	account := getAccount(t, testCtx)

	require.NotNil(t, account.ID)
	assert.True(t, strings.EqualFold(testCtx.resourceID, *account.ID), "resource ID mismatch: terraform=%s api=%s", testCtx.resourceID, *account.ID)
	require.NotNil(t, account.Name)
	assert.Equal(t, testCtx.accountName, *account.Name)

	require.NotNil(t, account.Kind)
	assert.Equal(t, expected.kind, *account.Kind)
	require.NotNil(t, account.SKU)
	require.NotNil(t, account.SKU.Name)
	assert.Equal(t, expected.sku, *account.SKU.Name)

	require.NotNil(t, account.Properties)
	require.NotNil(t, account.Properties.Endpoint)
	assert.Equal(t, testCtx.endpoint, *account.Properties.Endpoint)
	require.NotNil(t, account.Properties.CustomSubDomainName)
	assert.Equal(t, testCtx.customSubdomain, *account.Properties.CustomSubDomainName)
	require.NotNil(t, account.Properties.DisableLocalAuth)
	// Azure reports the inverse of Terraform's local_auth_enabled setting.
	assert.Equal(t, !expected.localAuthEnabled, *account.Properties.DisableLocalAuth)

	expectedAccess := armcognitiveservices.PublicNetworkAccessDisabled
	if expected.publicNetworkAccessEnabled {
		expectedAccess = armcognitiveservices.PublicNetworkAccessEnabled
	}
	require.NotNil(t, account.Properties.PublicNetworkAccess)
	assert.Equal(t, expectedAccess, *account.Properties.PublicNetworkAccess)

	for key, want := range expected.tags {
		got, ok := account.Tags[key]
		require.True(t, ok, "tag %q missing on account", key)
		require.NotNil(t, got)
		assert.Equal(t, want, *got, "tag %q mismatch", key)
	}

	tfOptions := ctx.TerratestTerraformOptions()
	outputContext := t.Context()
	assert.Equal(t, expected.kind, terraform.OutputContext(t, outputContext, tfOptions, "kind"))
	assert.Equal(t, expected.sku, terraform.OutputContext(t, outputContext, tfOptions, "sku_name"))
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
