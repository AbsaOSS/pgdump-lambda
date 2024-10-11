resource "aws_cloudwatch_log_group" "lambda_cloudwatch_group" {
  name              = "/aws/lambda/${aws_lambda_function.pgdump_lambda.function_name}"
  retention_in_days = 30
  kms_key_id        = var.kms_encryption_key_arn
}
