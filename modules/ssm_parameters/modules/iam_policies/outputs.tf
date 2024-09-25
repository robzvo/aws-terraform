output "snowflake_aws_credentials_read_only_policy" {
  value = {
    arn = aws_iam_policy.snowflake_aws_credentials_read_only_policy.arn,
    description = "Read Only IAM Policy for retrieving Snowflake AWS Credentials"
  }
}