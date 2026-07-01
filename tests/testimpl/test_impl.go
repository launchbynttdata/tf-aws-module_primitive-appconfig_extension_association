package testimpl

import (
	"context"
	"strconv"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/appconfig"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestComposableComplete verifies the deployed AppConfig extension association.
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	verifyExtensionAssociation(t, ctx)
}

// TestComposableCompleteReadOnly verifies the deployed AppConfig extension association using read-only AWS API calls.
func TestComposableCompleteReadOnly(t *testing.T, ctx types.TestContext) {
	verifyExtensionAssociation(t, ctx)
}

func verifyExtensionAssociation(t *testing.T, ctx types.TestContext) {
	opts := ctx.TerratestTerraformOptions()
	region := terraform.Output(t, opts, "region")
	id := terraform.Output(t, opts, "id")
	arn := terraform.Output(t, opts, "arn")
	extensionARN := terraform.Output(t, opts, "extension_arn")
	resourceARN := terraform.Output(t, opts, "resource_arn")
	extensionVersion := int32Output(t, ctx, "extension_version")

	require.NotEqual(t, "", id)
	assert.Equal(t, terraform.Output(t, opts, "expected_extension_arn"), extensionARN)
	assert.Equal(t, terraform.Output(t, opts, "expected_resource_arn"), resourceARN)

	client := appConfigClient(t, region)
	association, err := client.GetExtensionAssociation(context.Background(), &appconfig.GetExtensionAssociationInput{ExtensionAssociationId: aws.String(id)})
	require.NoError(t, err)

	assert.Equal(t, id, aws.ToString(association.Id))
	assert.Equal(t, arn, aws.ToString(association.Arn))
	assert.Equal(t, extensionARN, aws.ToString(association.ExtensionArn))
	assert.Equal(t, resourceARN, aws.ToString(association.ResourceArn))
	assert.Equal(t, extensionVersion, association.ExtensionVersionNumber)
}

func appConfigClient(t *testing.T, region string) *appconfig.Client {
	t.Helper()

	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
	require.NoError(t, err)

	return appconfig.NewFromConfig(cfg)
}

func int32Output(t *testing.T, ctx types.TestContext, name string) int32 {
	t.Helper()

	value, err := strconv.ParseInt(terraform.Output(t, ctx.TerratestTerraformOptions(), name), 10, 32)
	require.NoError(t, err)

	return int32(value)
}
