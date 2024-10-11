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
resource "aws_lambda_function" "pgdump_lambda" {
  filename      = data.archive_file.lambda_pgdump_archive.output_path
  function_name = "${data.aws_ssm_parameter.account_alias.value}-${var.project_name}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 900
  source_code_hash = filebase64sha256(data.archive_file.lambda_pgdump_archive.output_path)
  memory_size   = 4096
  ephemeral_storage {
    size = 8096
  }

  vpc_config {
    subnet_ids = data.aws_subnets.subnets.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      "PGDUMP_ARGS" = "-n config"
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
