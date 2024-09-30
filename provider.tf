terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}
provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key_id  # Refer to variables or environment variables
  secret_key = var.aws_secret_access_key  # Refer to variables or environment variables
}


