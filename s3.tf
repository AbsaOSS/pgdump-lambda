resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${data.aws_ssm_parameter.account_alias.value}-${var.aws_region_tag}-${data.aws_ssm_parameter.param_environment_type.value}-${var.team_code}-dbbackup"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.lambda_bucket.id

  rule {
    id = "two-weeks-old-objects"
    status = "Enabled"

    expiration {
      days = 14
    }
  }

  rule {
    id = "incomplete-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
