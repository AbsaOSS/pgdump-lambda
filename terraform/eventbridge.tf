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
resource "aws_cloudwatch_event_rule" "every_day_at_10pm" {
  name = "${data.aws_ssm_parameter.account_alias.value}-cron-pgdump-every-day-at-10pm"
  schedule_expression = "cron(0 21 * * ? *)"
  description = "Run pg_dump every day at 9pm UTC"
}

resource "aws_cloudwatch_event_target" "run_lambda_every_day_at_10pm" {
  for_each = var.backup_schedules

  rule = aws_cloudwatch_event_rule.every_day_at_10pm.name
  target_id = each.key
  arn = aws_lambda_function.pgdump_lambda.arn

  input = <<JSON
{
  "SECRET": "${each.value.db_credentials_parameter}",
  "REGION": "af-south-1",
  "S3_BUCKET": "${aws_s3_bucket.lambda_bucket.id}",
  "PREFIX": "${each.value.bucket_object_id_prefix}",
  "SECRET_SOURCE": "${each.value.secret_source}"
}
JSON
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_pgdump_lambda" {
  statement_id = "allow_pgdump_execution_from_cloudwatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pgdump_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.every_day_at_10pm.arn
}
