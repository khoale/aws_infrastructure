resource "aws_iam_role" "sd1572" {
  name               = "sd1572-${var.project}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.trust-policies-sd1572-assume-role.json
}

resource "aws_iam_role" "sd1572_2" {
  name               = "sd1572-${var.project}-0002"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.trust-policies-sd1572-assume-role.json
}

resource "aws_iam_role_policy" "sd1572" {
  name   = "sd1572-role-${var.project}-policy"
  role   = aws_iam_role.sd1572.id
  policy = data.aws_iam_policy_document.sd1572-role-policy.json
}

data "aws_iam_policy_document" "trust-policies-sd1572-assume-role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# We define what sd1572 role can do here Identity-base policies

data "aws_iam_policy_document" "sd1572-role-policy" {
  statement {
    actions = [
      "*"
    ]

    resources = [
      "arn:aws:s3:::terraform-boostrap-nashtech-devops"
    ]
  }
}
