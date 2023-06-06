resource "aws_dynamodb_table" "ec2_state_table" {
  name           = "terraform-ec2-ws-${var.name}-${var.project}"
  hash_key       = "LockID"
  read_capacity  = 3
  write_capacity = 3
  billing_mode   = "PROVISIONED"

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = module.labels.tags
}