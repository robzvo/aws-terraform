provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "%USERPROFILE%/tf_user/.aws/creds"
  profile                 = "customprofile"
}

resource "random_string" "random" {
  length = 16
}