# Configure AWS Provider
provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["C:\\Users\\rober\\.aws\\credentials"]
}

locals {
  vpc_name               = "${var.environment}_vpc"
  lambda_function_1_name = "tf-${var.lambda-function-1.Name}-${var.environment}"
  common_tags = {
    "environment" = var.environment
    "terraform"   = var.terraform
  }
  snowflake_aws_credentials_read_only_policy = module.ssm_parameters.snowflake_aws_credentials_read_only_policy
}

#Systems Manager Parameters Module
module "ssm_parameters" {
  source = "./modules/ssm_parameters"

  environment = var.environment
  aws_region = var.aws_region
}

#Systems Manager Parameters Module
module "code_build" {
  source = "./modules/code_build"

  environment = var.environment
  terraform = var.terraform
}

#Systems Manager Parameters Module
module "lambdas" {
  source = "./modules/lambda"

  environment = var.environment
  terraform = var.terraform
}