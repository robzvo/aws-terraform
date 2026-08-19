# AWS::Logs::LogGroup AgentLogGroup
#
# CloudFormation generated the log group name; here we generate an equivalent
# unique name so that repeated applies (and multiple agents in one account) do
# not collide.
resource "aws_cloudwatch_log_group" "agent" {
  name_prefix       = "/dagster-cloud/${var.dagster_organization}/agent-"
  retention_in_days = var.log_retention_in_days
}
