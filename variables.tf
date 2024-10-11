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
    db_secret_arn = string
    bucket_object_id_prefix = string
  }))
}

variable "permissions_boundary" {
  description = "The ARN of the permissions boundary to use for the IAM role"
}