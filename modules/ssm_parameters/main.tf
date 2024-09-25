resource "aws_ssm_parameter" "snowflake_aws_username" {
  name  = "/snowflake/aws/username/${var.environment}"
  type  = "SecureString"
  value = "changeme"
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "snowflake_aws_password" {
  name  = "/snowflake/aws/password/${var.environment}"
  type  = "SecureString"
  value = "changeme"
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "snowflake_aws_role" {
  name  = "/snowflake/aws/role/${var.environment}"
  type  = "SecureString"
  value = "changeme"
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "snowflake_aws_warehouse" {
  name  = "/snowflake/aws/warehouse/${var.environment}"
  type  = "SecureString"
  value = "changeme"
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

module "iam_policy_snowflake_aws_credentials_read_only" {
  source = "./modules/iam_policies"

  environment = var.environment
  ssm_parameter_arns = [
    aws_ssm_parameter.snowflake_aws_username.arn,
    aws_ssm_parameter.snowflake_aws_password.arn,
    aws_ssm_parameter.snowflake_aws_role.arn,
    aws_ssm_parameter.snowflake_aws_warehouse.arn
  ]
}