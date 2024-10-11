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
      "Sid": "",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "ArnEquals": {
          "AWS:SourceArn": "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${data.aws_ssm_parameter.account_alias.value}-${var.project_name}"
        }
      }
    }
  ]
}
EOF

  inline_policy {
    name   = "allow-ssm"
    policy = data.aws_iam_policy_document.allow_ssm_policy.json
  }
  
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
    name = "allow-secrets-manager"
    policy = data.aws_iam_policy_document.allow_secret_access.json
  }
  
  inline_policy {
    name = "allow-s3-access"
    policy = data.aws_iam_policy_document.allow_s3_access.json
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

data "aws_iam_policy_document" "allow_secret_access" {
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

data "aws_iam_policy_document" "allow_ssm_policy" {
  statement {
    actions   = ["ssm:PutParameter", "ssm:GetParam*", "ssm:AddTagsToResource"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/${var.team_code}/*"]
  }
}

data "aws_iam_policy_document" "allow_kms_policy" {
  statement {
    actions   = ["kms:*crypt*", "kms:GenerateDataKey*"]
    resources = ["arn:aws:kms:*:${var.kms_encryption_key_account_id}:key/*"]
  }
}

data "aws_iam_policy_document" "allow_database_connection" {
  statement {
    actions   = ["rds-db:connect"]
    resources = ["*"]
  }
}