resource "aws_ecr_repository" "dagster_user_code" {
  name                 = "dagster-ecs/user_code"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}