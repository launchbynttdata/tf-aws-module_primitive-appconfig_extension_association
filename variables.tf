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

# -----------------------------------------------------------------------------
# Required
# -----------------------------------------------------------------------------

variable "extension_arn" {
  description = "ARN of the AppConfig extension to associate."
  type        = string

  validation {
    condition     = can(regex("^arn:[^:]+:appconfig:", var.extension_arn))
    error_message = "extension_arn must be an AppConfig extension ARN."
  }
}
variable "resource_arn" {
  description = "ARN of the AppConfig resource to associate with the extension."
  type        = string

  validation {
    condition     = can(regex("^arn:[^:]+:appconfig:", var.resource_arn))
    error_message = "resource_arn must be an AppConfig resource ARN."
  }
}

# -----------------------------------------------------------------------------
# Optional
# -----------------------------------------------------------------------------

variable "parameters" {
  description = "Extension association parameters."
  type        = map(string)
  default     = null
}
variable "region" {
  description = "AWS Region where this resource is managed. Defaults to the provider-configured Region."
  type        = string
  default     = null
}
