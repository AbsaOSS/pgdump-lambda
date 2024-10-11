data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    SubnetType = "data"
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
