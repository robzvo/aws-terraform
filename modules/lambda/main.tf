data "aws_lambda_layer_version" "numpy_lambda_layer" {
  layer_name = "numpy-lambda-layer-${var.environment}"
}

data "archive_file" "layer_example_zip" {
  type             = "zip"
  source_dir       = "${path.module}/numpy-example"
  output_path      = "${path.module}/tmp/numpy-example-${var.environment}.zip"
  output_file_mode = "0666"
}

data "aws_iam_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_role" {
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

resource "aws_lambda_function" "numpy_lambda_example" {
  function_name = "numpy-lambda-example-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  description   = "Function demonstrating the use of NumPy Lambda layer"
  filename      = data.archive_file.layer_example_zip.output_path
  handler       = "index.lambda_handler"
  layers        = [data.aws_lambda_layer_version.numpy_lambda_layer.arn]
  runtime       = "python3.11"
  # source_code_hash is required to detect changes to Lambda code/zip
  source_code_hash = data.archive_file.layer_example_zip.output_base64sha256
}