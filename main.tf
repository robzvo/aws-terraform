# Configure AWS Provider
provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
}

data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {}

data "aws_availability_zones" "available" {
  state = "available"
}
