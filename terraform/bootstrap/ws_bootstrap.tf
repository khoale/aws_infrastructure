module "labels" {
  source = "../modules/tags"

  name        = var.name
  project     = var.project
  environment = var.environment
  owner       = var.owner

  tags = {
    Description = "Managed by Terraform", # Addtional tags if needed
  }
}


resource "aws_kms_key" "terraform-bootstrap" {
  description             = "Terraform Bootstrap KMS key"
  deletion_window_in_days = 14

  policy = data.aws_iam_policy_document.kms_use.json

  tags = module.labels.tags
}

resource "aws_kms_alias" "terraform-bootstrap" {
  name          = "alias/terraform-${var.name}-${var.project}"
  target_key_id = aws_kms_key.terraform-bootstrap.key_id
}

data "aws_iam_policy_document" "kms_use" {

  statement {
    sid       = "Enable Permissions for DevOps"
    effect    = "Allow"
    resources = ["*"]

    actions = ["kms:*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.devops.arn,
        "arn:aws:iam::377414509754:user/dat.nguyen"
      ]
    }
  }

  # statement {
  #   sid       = "Enable Permissions for Spectator"
  #   effect    = "Allow"
  #   resources = ["*"]

  #   actions = [
  #     "kms:List*",
  #     "kms:Get*",
  #     "kms:Decrypt",
  #     "kms:DescribeKey"
  #   ]

  #   principals {
  #     type = "AWS"
  #     identifiers = [
  #       aws_iam_user.spectator.arn
  #     ]
  #   }
  # }
}

resource "aws_s3_bucket" "bootstrap" {
  bucket = "terraform-${var.name}-${var.project}"

  tags = module.labels.tags

  depends_on = [aws_kms_key.terraform-bootstrap, aws_kms_alias.terraform-bootstrap]
}

resource "aws_s3_bucket_ownership_controls" "bootstrap" {  # https://stackoverflow.com/questions/76049290/error-accesscontrollistnotsupported-when-trying-to-create-a-bucket-acl-in-aws
  bucket = aws_s3_bucket.bootstrap.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bootstrap" {
  bucket = aws_s3_bucket.bootstrap.bucket
  acl    = "private"

  depends_on = [ aws_s3_bucket_ownership_controls.bootstrap ]
}

resource "aws_s3_bucket_accelerate_configuration" "bootstrap" {
  bucket = aws_s3_bucket.bootstrap.bucket
  status = "Enabled"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bootstrap" {
  bucket = aws_s3_bucket.bootstrap.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform-bootstrap.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bootstrap.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "bootstrap-state-table" {
  name           = "terraform-${var.name}-${var.project}"
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

  depends_on = [aws_s3_bucket.bootstrap]
}
