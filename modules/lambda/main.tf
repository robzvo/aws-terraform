data "aws_lambda_layer_version" "example_lambda_layer" {
  layer_name = "test-lambda-layer"
}

data "archive_file" "layer_example_zip" {
  type             = "zip"
  source_dir       = "${path.module}/layer-example"
  output_path      = "${path.module}/tmp/layer-example.zip"
  output_file_mode = "0666"
}

data "aws_iam_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "layer_example" {
  name = "LayerExampleLambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [data.aws_iam_policy.lambda_basic_execution.arn]
}

resource "aws_lambda_function" "layer_example" {
  function_name = "layer-example"
  role          = aws_iam_role.layer_example.arn
  description   = "Function demonstrating the use of a Lambda layer"
  filename      = data.archive_file.layer_example_zip.output_path
  handler       = "index.lambda_handler"
  layers        = [data.aws_lambda_layer_version.example_lambda_layer.arn]
  runtime       = "python3.11"
  # source_code_hash is required to detect changes to Lambda code/zip
  source_code_hash = data.archive_file.layer_example_zip.output_base64sha256
}