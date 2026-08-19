####################################################################
# Shared trust policy for both task roles
####################################################################

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ecs:${local.region}:${local.account_id}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

####################################################################
# AWS::IAM::Role TaskExecutionRole
####################################################################

resource "aws_iam_role" "task_execution" {
  name_prefix        = "dagster-agent-exec-"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

####################################################################
# AWS::IAM::Role AgentRole
####################################################################

resource "aws_iam_role" "agent" {
  name_prefix        = "dagster-agent-task-"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

data "aws_iam_policy_document" "agent" {
  statement {
    sid    = "Secrets"
    effect = "Allow"
    actions = [
      "ecs:ListTagsForResource",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Describe"
    effect = "Allow"
    actions = [
      "ec2:DescribeRouteTables",
      "ec2:DescribeNetworkInterfaces",
      "ecs:ListAccountSettings",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManageServicesInCluster"
    effect = "Allow"
    actions = [
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:ListServices",
      "ecs:ListTasks",
      "ecs:RunTask",
      "ecs:StopTask",
      "ecs:UpdateService",
    ]
    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "ecs:cluster"
      values   = [aws_ecs_cluster.agent.arn]
    }
  }

  statement {
    sid       = "TagClusterResources"
    effect    = "Allow"
    actions   = ["ecs:TagResource"]
    resources = ["${aws_ecs_cluster.agent.arn}*"]
  }

  # No way to scope these down further :(
  statement {
    sid    = "TaskDefinitions"
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:TagResource",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "PassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }

  statement {
    sid       = "ReadAgentLogs"
    effect    = "Allow"
    actions   = ["logs:GetLogEvents"]
    resources = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.agent.name}:log-stream:*"]
  }

  statement {
    sid    = "ServiceDiscovery"
    effect = "Allow"
    actions = [
      "servicediscovery:ListServices",
      "servicediscovery:ListTagsForResource",
      "servicediscovery:ListInstances",
      "servicediscovery:DeregisterInstance",
      "servicediscovery:GetOperation",
      "servicediscovery:DeleteService",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "GetNamespace"
    effect    = "Allow"
    actions   = ["servicediscovery:GetNamespace"]
    resources = [aws_service_discovery_private_dns_namespace.agent.arn]
  }

  statement {
    sid     = "CreateServiceDiscoveryService"
    effect  = "Allow"
    actions = ["servicediscovery:CreateService", "servicediscovery:TagResource"]
    resources = [
      aws_service_discovery_private_dns_namespace.agent.arn,
      "arn:aws:servicediscovery:${local.region}:${local.account_id}:service/*",
    ]
  }

  statement {
    sid       = "GetResources"
    effect    = "Allow"
    actions   = ["tag:GetResources"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "agent" {
  name   = "root"
  role   = aws_iam_role.agent.id
  policy = data.aws_iam_policy_document.agent.json
}
