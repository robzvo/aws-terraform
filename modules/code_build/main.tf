

provider "aws" {}

data "aws_caller_identity" "this" {}

data "aws_partition" "this" {}

data "aws_region" "this" {}


locals {
  account_id = data.aws_caller_identity.this.account_id
  partition  = data.aws_partition.this.partition
  region     = data.aws_region.this.name
}

# IAM Role for AWS CodeBuild to use
resource "aws_iam_role" "code_build_iam_role" {
  name = "tf-code-build-lambda-layer-iam-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy to be attached to AWS CodeBuild Role
resource "aws_iam_role_policy" "code_build_iam_policy" {
  name = "tf-code-build-lambda-layer-policy-${var.environment}"
  role = aws_iam_role.code_build_iam_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:/aws/codebuild/*"
      },
      {
        Action = [
          "lambda:PublishLayerVersion"
        ],
        Effect   = "Allow"
        Resource = "arn:${local.partition}:lambda:${local.region}:${local.account_id}:layer:*"
      }
    ]
  })
}

# AWS CodeBuild Project for NumPy Lambda Layer
resource "aws_codebuild_project" "numpy_lambda_layer" {
  name         = "numpy-lambda-layer-build-${var.environment}"
  description  = "Build project for numpy-lambda-layer-build-${var.environment}"
  service_role = aws_iam_role.code_build_iam_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "LAYER_NAME"
      value = "numpy-lambda-layer-${var.environment}"
    }
  }
  source {
    buildspec = file("${path.module}/specs/numpy-lambda-layer.yml")
    type      = "NO_SOURCE"
  }
}

