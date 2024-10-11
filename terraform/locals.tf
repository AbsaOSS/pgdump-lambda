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
locals {
  tags = merge(tomap(var.custom_tags), tomap({
    "CostCenter"        = data.aws_ssm_parameter.param_cost_center.value
    "AppId"             = data.aws_ssm_parameter.param_app_id.value
    "TeamCode"          = var.team_code
    "Environment"       = data.aws_ssm_parameter.param_environment_type.value
    "TeamEmailAddress"  = data.aws_ssm_parameter.param_team_email.value
    "Application"       = data.aws_ssm_parameter.param_application.value
    "Name"              = var.project_name
    "BuiltBy"           = "Terraform"
    "Project"           = var.project_name
  }))

  required_parameters = [for schedule in var.backup_schedules : schedule.db_credentials_parameter if schedule.secret_source == "SSM"]
  required_secrets = [for schedule in var.backup_schedules : schedule.db_credentials_parameter if schedule.secret_source == "SECRETS_MANAGER"]
}

