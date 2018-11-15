resource "aws_dynamodb_table" "bl_vault_dynamodb_table" {
  name           = "bl-${var.app_name}-${var.stack}-${var.namespace}"
  read_capacity  = "${var.dynamodb_read_capacity}"
  write_capacity = "${var.dynamodb_write_capacity}"
  hash_key       = "Path"
  range_key      = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags {
    Name        = "bl-${var.app_name}-${var.stack}-${var.namespace}"
  }
}