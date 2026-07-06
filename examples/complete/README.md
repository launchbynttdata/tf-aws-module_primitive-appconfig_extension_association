# Complete Example

This example creates a complete AppConfig extension association deployment with the dependencies required to exercise the primitive module.

## Usage

```hcl
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

data "aws_region" "current" {}


module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length

  region = join("", split("-", data.aws_region.current.region))
}

resource "aws_appconfig_application" "example" {
  name = module.resource_names["application"].standard
  tags = var.tags
}

resource "aws_sns_topic" "extension" {
  name = module.resource_names["sns_topic"].minimal_random_suffix
  tags = var.tags
}

resource "aws_appconfig_extension" "example" {
  name = module.resource_names["extension"].standard
  parameter {
    name        = "NotificationMode"
    description = "Controls notification behavior for the test association."
    required    = true
  }

  action_point {
    point = "PRE_CREATE_HOSTED_CONFIGURATION_VERSION"
    action {
      name = "Notify"
      uri  = aws_sns_topic.extension.arn
    }
  }
  tags = var.tags
}

module "extension_association" {
  source = "../.."

  extension_arn = aws_appconfig_extension.example.arn
  parameters    = { NotificationMode = "default" }
  resource_arn  = aws_appconfig_application.example.arn
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_extension_association"></a> [extension\_association](#module\_extension\_association) | ../.. | n/a |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appconfig_application.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_application) | resource |
| [aws_appconfig_extension.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_extension) | resource |
| [aws_iam_role.extension](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.extension](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_sns_topic.extension](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_iam_policy_document.appconfig_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_publish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class for generated resource names. | `string` | n/a | yes |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Environment instance number for generated resource names. | `number` | n/a | yes |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Resource instance number for generated resource names. | `number` | n/a | yes |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for generated resource names. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for generated resource names. | `string` | n/a | yes |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Resource name configuration keyed by resource role. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the extension association. |
| <a name="output_expected_extension_arn"></a> [expected\_extension\_arn](#output\_expected\_extension\_arn) | Expected extension ARN. |
| <a name="output_expected_parameters"></a> [expected\_parameters](#output\_expected\_parameters) | Expected extension association parameters. |
| <a name="output_expected_resource_arn"></a> [expected\_resource\_arn](#output\_expected\_resource\_arn) | Expected resource ARN. |
| <a name="output_extension_arn"></a> [extension\_arn](#output\_extension\_arn) | The associated extension ARN. |
| <a name="output_extension_version"></a> [extension\_version](#output\_extension\_version) | The extension version. |
| <a name="output_id"></a> [id](#output\_id) | The extension association ID. |
| <a name="output_parameters"></a> [parameters](#output\_parameters) | The extension association parameters. |
| <a name="output_region"></a> [region](#output\_region) | The AWS Region where the example resources are deployed. |
| <a name="output_resource_arn"></a> [resource\_arn](#output\_resource\_arn) | The associated resource ARN. |
<!-- END_TF_DOCS -->
