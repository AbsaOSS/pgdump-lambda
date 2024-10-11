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
  
  required_secrets = [for schedule in var.backup_schedules : schedule.db_secret_arn]
}

