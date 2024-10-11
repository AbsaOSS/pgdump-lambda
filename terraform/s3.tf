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
