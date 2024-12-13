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
resource "aws_iam_role" "iam_for_lambda" {
  name                  = "${var.team_code}-${var.project_name}"
  permissions_boundary  = var.permissions_boundary
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name   = "allow-kms"
    policy = data.aws_iam_policy_document.allow_kms_policy.json
  }

  inline_policy {
    name   = "allow-e2-network-interfaces"
    policy = data.aws_iam_policy_document.allow_vpc_network_interfaces.json
  }

  inline_policy {
    name   = "allow-logging"
    policy = data.aws_iam_policy_document.allow_logging_policy.json
  }

  inline_policy {
    name = "allow-database-connection"
    policy = data.aws_iam_policy_document.allow_database_connection.json
  }

  inline_policy {
    name = "allow-s3-access"
    policy = data.aws_iam_policy_document.allow_s3_access.json
  }

  dynamic "inline_policy" {
    for_each = length(local.required_parameters) > 0 ? [1] : []
    content {
      name = "allow-ssm"
      policy = data.aws_iam_policy_document.allow_ssm_access.json
    }
  }

  dynamic "inline_policy" {
    for_each = length(local.required_secrets) > 0 ? [1] : []
    content {
      name = "allow-secrets-manager"
      policy = data.aws_iam_policy_document.allow_secrets_access.json
    }
  }
}

data "aws_iam_policy_document" "allow_vpc_network_interfaces" {
  statement {
    actions   = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "allow_ssm_access" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [for par in local.required_parameters: "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter${par}"]
  }
}

data "aws_iam_policy_document" "allow_secrets_access" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = local.required_secrets
  }
}

data "aws_iam_policy_document" "allow_s3_access" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.lambda_bucket.arn}/*"]
  }
}

data "aws_iam_policy_document" "allow_logging_policy" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "allow_kms_policy" {
  statement {
    actions   = ["kms:*crypt*", "kms:GenerateDataKey*"]
    resources = ["arn:aws:kms:*:${var.kms_encryption_key_account_id}:key/*", "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"]
  }
}

data "aws_iam_policy_document" "allow_database_connection" {
  statement {
    actions   = ["rds-db:connect"]
    resources = ["*"]
  }
}
