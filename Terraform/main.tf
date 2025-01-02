terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  # region  = "us-east-1"
}

resource "aws_dynamodb_table" "session" {
  name = "session"

  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "userId"
  range_key = "refreshTokenHash"

  attribute {
    name = "userId"
    type = "S"  # String data type
  }

  attribute {
    name = "refreshTokenHash"
    type = "S"
  }
}