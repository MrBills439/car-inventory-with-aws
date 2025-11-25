resource "aws_dynamodb_table" "cars" {
  name         = "${var.project_name}-Cars"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "carId"

  attribute {
    name = "carId"
    type = "S"
  }

  tags = {
    Project = var.project_name
    Owner   = "Felix"
  }
}