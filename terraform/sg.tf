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
resource "aws_security_group" "lambda_sg" {
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  name                   = "${var.team_code}-${var.project_name}-sg"
  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "lambda_sg_all_egress" {
  description       = "All egress traffic"
  security_group_id = aws_security_group.lambda_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks = ["0.0.0.0/0"]
}
