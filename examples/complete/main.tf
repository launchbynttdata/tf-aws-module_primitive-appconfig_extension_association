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

data "aws_iam_policy_document" "appconfig_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["appconfig.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sns_publish" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.extension.arn]
  }
}

resource "aws_iam_role" "extension" {
  name               = module.resource_names["iam_role"].standard
  assume_role_policy = data.aws_iam_policy_document.appconfig_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "extension" {
  name   = "${module.resource_names["iam_role"].standard}-sns-publish"
  role   = aws_iam_role.extension.id
  policy = data.aws_iam_policy_document.sns_publish.json
}

resource "aws_appconfig_extension" "example" {
  name = module.resource_names["extension"].standard
  parameter {
    name        = "NotificationMode"
    description = "Controls notification behavior for the test association."
    required    = true
  }

  action_point {
    point = "ON_DEPLOYMENT_COMPLETE"
    action {
      name     = "Notify"
      uri      = aws_sns_topic.extension.arn
      role_arn = aws_iam_role.extension.arn
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
