# Configure AWS Provider
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:\\Users\\rober\\.aws\\credentials"]
}

locals {
  vpc_name               = "${var.environment}_vpc"
  lambda_function_1_name = "tf-${var.lambda-function-1.Name}-${var.environment}"
  common_tags = {
    "environment" = var.environment
    "terraform"   = var.terraform
  }
}

#Systems Manager Parameters Module
module "ssm_parameters" {
  source = "./modules/ssm_parameters"

  environment = var.environment
}