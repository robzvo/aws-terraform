resource "aws_ecs_service" "main" {
  name            = "my-fargate-service"
  cluster         = aws_ecs_cluster.dagster_ecs_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id,aws_subnet.subnet_c.id] # Pass your VPC private/public subnets
    # security_groups  = ["sg-xxxxxxxxxxxx"]                         # Pass your Security Group ID
    assign_public_ip = true                                         # True if public subnet, False if private subnet
  }
}