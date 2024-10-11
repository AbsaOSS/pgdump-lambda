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