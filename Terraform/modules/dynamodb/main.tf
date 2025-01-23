
resource "aws_dynamodb_table" "user" {
  name = "${var.table_name_prefix}_auth_user"

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

resource "aws_dynamodb_table" "user_email_method" {
  name         = "${var.table_name_prefix}_auth_user_email_method"
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
  name = "${var.table_name_prefix}_auth_session"

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
