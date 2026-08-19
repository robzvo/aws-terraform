output "template_version" {
  description = "The revision of the ECS agent template this project was ported from."
  value       = local.template_version
}

output "vpc_id" {
  description = "ID of the VPC created for the agent."
  value       = aws_vpc.agent.id
}

output "subnet_ids" {
  description = "IDs of the public subnets the agent and its code servers run in."
  value       = local.subnet_ids
}

output "cluster_name" {
  description = "Name of the ECS cluster running the agent."
  value       = aws_ecs_cluster.agent.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster running the agent."
  value       = aws_ecs_cluster.agent.arn
}

output "service_name" {
  description = "Name of the ECS service running the agent."
  value       = aws_ecs_service.agent.name
}

output "task_definition_arn" {
  description = "ARN of the agent task definition."
  value       = aws_ecs_task_definition.agent.arn
}

output "log_group_name" {
  description = "CloudWatch log group the agent and code servers log to."
  value       = aws_cloudwatch_log_group.agent.name
}

output "service_discovery_namespace_id" {
  description = "ID of the private DNS namespace used for code server service discovery."
  value       = aws_service_discovery_private_dns_namespace.agent.id
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  value       = aws_iam_role.task_execution.arn
}

output "agent_role_arn" {
  description = "ARN of the agent task role."
  value       = aws_iam_role.agent.arn
}
