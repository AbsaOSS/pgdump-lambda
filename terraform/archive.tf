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
data "archive_file" "lambda_pgdump_archive" {
  type = "zip"

  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda_pgdump.zip"

  excludes = [
    ".git/*",
    ".git*",
    ".terraform",
    "terraform*",
    ".terraform/*",
    ".gitignore",
    ".DS_Store",
    "terraform.tfstate*",
    "terraform.tfvars*",
    "*.tf",
    ".idea",
    "*.zip"
  ]
}
