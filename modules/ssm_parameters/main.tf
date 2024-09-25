locals {
  ssm_param_group = [
    aws_ssm_parameter.ssm_param.arn
  ]
}
resource "aws_ssm_parameter" "ssm_param" {
  name  = "/database/schema/username/password/${var.environment}"
  type  = "SecureString"
  value = "changeme"
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

module "iam_policy_ssm_param_group" {
  source = "./modules/iam_policies"

  environment = var.environment
  ssm_parameter_arns = [
    aws_ssm_parameter.ssm_param.arn
  ]
}