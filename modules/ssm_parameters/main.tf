resource "aws_ssm_parameter" "ssm_param" {
  name        = "/database/schema/username/password/${var.environment}"
  type        = "SecureString"
  value       = "changeme"
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}