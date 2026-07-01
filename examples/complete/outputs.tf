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

output "id" {
  description = "The extension association ID."
  value       = module.extension_association.id
}
output "arn" {
  description = "The ARN of the extension association."
  value       = module.extension_association.arn
}
output "extension_arn" {
  description = "The associated extension ARN."
  value       = module.extension_association.extension_arn
}
output "extension_version" {
  description = "The extension version."
  value       = module.extension_association.extension_version
}
output "resource_arn" {
  description = "The associated resource ARN."
  value       = module.extension_association.resource_arn
}
output "expected_extension_arn" {
  description = "Expected extension ARN."
  value       = aws_appconfig_extension.example.arn
}
output "expected_resource_arn" {
  description = "Expected resource ARN."
  value       = aws_appconfig_application.example.arn
}

output "region" {
  description = "The AWS Region where the example resources are deployed."
  value       = data.aws_region.current.region
}
