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
terraform {
  backend "s3" {
    # use --backend-config bucket=xxx  to set the bucket name
    region          = "af-south-1"
    encrypt         = true
    key             = "pgdump_lambda/terraform.tfstate"
    acl             = "private"
    dynamodb_table  = "dynamodb-state-locking"
  }
}
