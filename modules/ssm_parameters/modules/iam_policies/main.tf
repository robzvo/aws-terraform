resource "aws_iam_policy" "snowflake_aws_credentials_read_only_policy" {
  name        = "ssm-param-read-only-${var.environment}"
  path        = "/"
  description = "Read only access for Snowflake AWS credentials in ${var.environment} environment"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DescribeParameters",
        ]
        Effect   = "Allow"
        Resource = [
          for arn in var.ssm_parameter_arns:
           "${arn}"
        ]
      },
    ]
  })
}