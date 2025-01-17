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
}

resource "aws_dynamodb_table" "user" {
  name = "dev_auth_user"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Unique constraint can not be achieve with an gsi
  # global_secondary_index {
  #   name               = "emailIndex"
  #   hash_key           = "email"
  #   projection_type    = "INCLUDE"
  #   non_key_attributes = ["passwordHash"]
  # }
}

resource "aws_dynamodb_table" "user_email" {
  name         = "dev_auth_user_email_method"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "email"

  attribute {
    name = "email"
    type = "S"
  }

  # passwordHash: S
  # userId: S
}

resource "aws_dynamodb_table" "session" {
  // TODO: create reusable modules to create the same resources on different envs
  name = "dev_auth_session"

  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "userId"
  range_key = "subId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "subId"
    type = "S"
  }
}
