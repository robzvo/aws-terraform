resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "robzvo-terraform-${var.environment}"

  tags = {
    Name = "Terraform managed resources bucket for ${var.environment} environment"
  }
}

# disables ACLs
resource "aws_s3_bucket_ownership_controls" "terraform_bucket_controls" {
  bucket = aws_s3_bucket.terraform_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#sets versioning for all objects in S3 bucket
resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}