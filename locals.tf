locals {
  # Version of the upstream CloudFormation template this project was ported from.
  template_version = "1.13.18"

  # CFN pseudo-parameters AWS::Region / AWS::AccountId
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id

  # CFN condition: IsDeploymentEmpty
  is_deployment_empty = var.dagster_deployment == ""

  # CFN condition: IsZeroDowntimeDeploysEnabled
  is_zero_downtime_deploys_enabled = var.enable_zero_downtime_deploys

  # CFN: !If [IsDeploymentEmpty, "", !Sub "deployment: ${DagsterDeployment}"]
  deployment_config = local.is_deployment_empty ? "" : "deployment: ${var.dagster_deployment}"

  # CFN: !Sub "Dagster-Cloud-${DagsterOrganization}-${DagsterDeployment}-Cluster"
  # Note the doubled dash when the deployment is empty; this reproduces the
  # CloudFormation naming exactly.
  cluster_name = "${var.name_prefix}-${var.dagster_organization}-${var.dagster_deployment}-Cluster"

  # CFN derived the namespace suffix from the last group of the stack UUID.
  # random_id gives us an equivalent stable, per-deployment 12-hex-char suffix.
  service_discovery_namespace_name = "dagster-agent-${var.dagster_organization}-${var.dagster_deployment}-${random_id.namespace_suffix.hex}.local"

  subnet_ids = aws_subnet.agent[*].id

  # The container command that writes $DAGSTER_HOME/dagster.yaml and starts the
  # agent. Kept byte-for-byte equivalent to the CloudFormation !Sub block.
  agent_command = trimsuffix(templatefile("${path.module}/templates/agent_command.tftpl", {
    dagster_organization           = var.dagster_organization
    agent_token                    = var.agent_token
    deployment_config              = local.deployment_config
    branch_deployments             = tostring(var.enable_branch_deployments)
    cluster                        = aws_ecs_cluster.agent.name
    subnets                        = join(",", local.subnet_ids)
    service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.agent.id
    execution_role_arn             = aws_iam_role.task_execution.arn
    task_role_arn                  = aws_iam_role.agent.arn
    log_group                      = aws_cloudwatch_log_group.agent.name
    requires_healthcheck           = tostring(var.enable_zero_downtime_deploys)
    code_server_metrics_enabled    = tostring(var.code_server_metrics_enabled)
    agent_metrics_enabled          = tostring(var.agent_metrics_enabled)
  }), "\n")
}
