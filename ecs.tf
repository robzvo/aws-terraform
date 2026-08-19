####################################################################
# AWS::ECS::Cluster AgentCluster
####################################################################

resource "aws_ecs_cluster" "agent" {
  name = local.cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "agent" {
  cluster_name       = aws_ecs_cluster.agent.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

####################################################################
# AWS::ECS::TaskDefinition AgentTaskDefinition
####################################################################

resource "aws_ecs_task_definition" "agent" {
  family                   = "${var.name_prefix}-${var.dagster_organization}-${var.dagster_deployment}-Agent"
  cpu                      = var.agent_cpu
  memory                   = var.agent_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.agent.arn

  container_definitions = jsonencode([
    merge(
      {
        name      = "DagsterAgent"
        image     = var.agent_image
        essential = true

        environment = [
          {
            name  = "DAGSTER_HOME"
            value = "/opt/dagster/dagster_home"
          },
          {
            name  = "DAGSTER_CLOUD_AGENT_MEMORY_LIMIT"
            value = var.agent_memory
          },
          {
            name  = "DAGSTER_CLOUD_AGENT_CPU_LIMIT"
            value = var.agent_cpu
          },
        ]

        entryPoint  = ["bash", "-c"]
        command     = [local.agent_command]
        stopTimeout = 120

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.agent.name
            awslogs-region        = local.region
            awslogs-stream-prefix = "agent"
          }
        }
      },
      # Only attached when zero-downtime deploys are enabled, mirroring the
      # CloudFormation !If [...] / AWS::NoValue construct.
      local.is_zero_downtime_deploys_enabled ? {
        healthCheck = {
          command = ["CMD-SHELL", "test -f /opt/finished_initial_reconciliation_sentinel.txt"]
          # We intentionally extend Interval, StartPeriod, and Retries beyond the
          # defaults because the initial reconciliation loop can take anywhere
          # from 3-15 minutes to complete - only upon which is the new agent
          # ready to serve requests.
          # Time (seconds) between subsequent health checks.
          interval = 60
          # Grace period to provide time to bootstrap the container before
          # performing health checks.
          startPeriod = 300
          retries     = 10
        }
      } : {},
    )
  ])
}

####################################################################
# AWS::ECS::Service AgentService
####################################################################

resource "aws_ecs_service" "agent" {
  name            = "${var.name_prefix}-${var.dagster_organization}-${var.dagster_deployment}-Agent"
  cluster         = aws_ecs_cluster.agent.id
  task_definition = aws_ecs_task_definition.agent.arn
  desired_count   = var.num_replicas
  launch_type     = "FARGATE"

  # Prevents two agent tasks running simultaneously in update scenarios unless
  # zero-downtime deploys are enabled.
  deployment_maximum_percent         = local.is_zero_downtime_deploys_enabled ? 200 : 100
  deployment_minimum_healthy_percent = local.is_zero_downtime_deploys_enabled ? 100 : 0

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = local.subnet_ids
    assign_public_ip = true
    # No security group is specified, so the VPC's default security group is
    # used - the same behaviour as the CloudFormation template.
  }

  depends_on = [
    aws_route_table_association.public,
    aws_route.to_gateway,
    # Not in the CloudFormation template, but ensures the agent never starts
    # before it is allowed to call ECS/Service Discovery.
    aws_iam_role_policy.agent,
    aws_iam_role_policy_attachment.task_execution,
  ]
}
