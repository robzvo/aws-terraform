# Configure AWS Provider
provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
}

data "aws_caller_identity" "current" {}
data "aws_partition" "this" {}
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}
