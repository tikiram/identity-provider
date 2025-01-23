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

module "dynamodb" {
  source = "../modules/dynamodb"

  table_name_prefix = "prod"
}