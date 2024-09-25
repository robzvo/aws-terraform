variable "environment" {

}

variable "terraform" {

}

variable "aws_region" {

}

variable "lambda-function-1" {
  default = {
    Name           = "lambda-function-1"
    src            = "source_code/lambda-function-1"
    PythonFile     = "driver"
    PythonFunction = "main"
    description    = "My lambda-function-1 description"
  }
}