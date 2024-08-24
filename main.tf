# Configure AWS Provider
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:\\Users\\rober\\.aws\\credentials"]
}

locals {
  vpc_name = "${var.environment}_vpc"
}

resource "aws_vpc" "vpc" {
  tags = {
    "name"        = local.vpc_name
    "environment" = var.environment
    "terraform"   = var.terraform
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# data "archive_file" "lambda_function_1" {
#   type        = "zip"
#   source_file = "source_code/lambda-function-1/driver.py"
#   output_path = "lambda-function-1.zip"
# }

data "archive_file" "lambda_function_1" {
  type        = "zip"
  output_path = "${path.module}/zipped/lambda-function-1.zip"

  source_dir = "source_code/lambda-function-1"

# source {
#     filename = "driver.py"
#     content = file("source_code/lambda-function-1/driver.py")
#   }
#   source {
#     filename = "utilities.py"
#     content = file("source_code/lambda-function-1/utilities.py")
#   }
}

resource "aws_lambda_function" "lambda_function_1" {
  function_name = "lambda-function-1"
  role          = aws_iam_role.iam_for_lambda.arn

  filename      = "lambda-function-1.zip"
  handler       = "driver.main"
  runtime       = "python3.11"
  memory_size   = 1769
  timeout = 90

  ephemeral_storage {
    size = 512 # Min 512 MB and the Max 10240 MB
  }
}