# Copyright 2024 ABSA Group Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
variable "aws_profile" {
  type = string
}

variable "team_code" {
  description = "Team Code for the AWS account"
}

variable "project_name" {
  description = "Project name. Used as a default resource name and for the project tag"

}

variable "aws_region" {
  description = "The AWS region to provision the resources into"
  default     = "af-south-1"
}

variable "aws_region_tag" { default = "afs1" }

variable "custom_tags" {
  description = "Additional custom tags"
  default     = {}
}

variable "environment" {
  description = "The environment to deploy resources."
  default     = "test"
}

variable "vpc_id" {
  type = string
}

variable "kms_encryption_key_account_id" {
  type = string
}

variable "kms_encryption_key_arn" {
  type = string
}

variable "backup_schedules" {
  type = map(object({
    name = string
    db_credentials_parameter = string
    bucket_object_id_prefix = string
    secret_source = string
  }))
}

variable "permissions_boundary" {
  description = "The ARN of the permissions boundary to use for the IAM role"
}
