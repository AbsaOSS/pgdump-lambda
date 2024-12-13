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
data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "account_alias" {
  name            = "/${var.team_code}/common_values/account_alias"
  with_decryption = true
  provider        = aws.aws_read_only
}

data "aws_ssm_parameter" "param_app_id" {
  name            = "/${var.team_code}/common_values/appId"
  with_decryption = true
  provider        = aws.aws_read_only
}

data "aws_ssm_parameter" "param_cost_center" {
  name            = "/${var.team_code}/common_values/costCenter"
  with_decryption = true
  provider        = aws.aws_read_only
}

data "aws_ssm_parameter" "param_team_email" {
  name            = "/${var.team_code}/common_values/teamEmailAddress"
  with_decryption = true
  provider        = aws.aws_read_only
}

data "aws_ssm_parameter" "param_application" {
  name            = "/${var.team_code}/common_values/application"
  with_decryption = true
  provider        = aws.aws_read_only
}

data "aws_ssm_parameter" "param_environment_type" {
  name            = "/${var.team_code}/common_values/environmentType"
  with_decryption = true
  provider        = aws.aws_read_only
}

data "aws_ssm_parameter" "vpc_id" {
  name            = "/${var.team_code}/common_values/vpcId"
  with_decryption = true
  provider        = aws.aws_read_only
}
