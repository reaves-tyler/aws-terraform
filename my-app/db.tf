resource "aws_dynamodb_table" "terraform-lock" {
  name         = "crud-table-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  attribute {
    name = "PK"
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB CRUD Table"
  }
}
