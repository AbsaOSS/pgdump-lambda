resource "aws_lambda_function" "pgdump_lambda" {
  filename      = data.archive_file.lambda_pgdump_archive.output_path
  function_name = "${data.aws_ssm_parameter.account_alias.value}-${var.project_name}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 900
  source_code_hash = filebase64sha256(data.archive_file.lambda_pgdump_archive.output_path)
  memory_size   = 2048
  ephemeral_storage {
    size = 8096
  }

  vpc_config {
    subnet_ids = data.aws_subnets.subnets.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {

    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pgdump_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:af-south-1:${data.aws_caller_identity.current.account_id}:rule/*"
}