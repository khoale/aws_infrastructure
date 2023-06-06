resource "aws_iam_group" "devops" {
  name = "devops-${var.project}"
  path = "/devops-${var.project}/"
}

resource "aws_iam_group_policy" "devops_policy" {
  name   = "devops-${var.project}-policy"
  group  = aws_iam_group.devops.name
  policy = data.aws_iam_policy_document.devops-assume-role-policy.json
}

resource "aws_iam_role" "devops" {
  name               = "devops-${var.project}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.trust-policies-devops-assume-role.json
}

resource "aws_iam_role_policy" "devops" {
  name   = "devops-role-${var.project}-policy"
  role   = aws_iam_role.devops.id
  policy = data.aws_iam_policy_document.devops-role-policy.json
}

data "aws_iam_policy_document" "devops-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      aws_iam_role.devops.arn
    ]
  }
}

# Define what user/service have permission to execute the AssumeRole action is needed
# We have a Role and we should define what user/service can assume that role
# Note: "group" is not a valid principals https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_principal.html
data "aws_iam_policy_document" "trust-policies-devops-assume-role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"
      identifiers = [
        for user in local.devops : user.arn
      ]
    }
  }
}

# We define what devops role can do here Identity-base policies

data "aws_iam_policy_document" "devops-role-policy" {
  statement {
    actions = [
      "*"
    ]

    resources = [
      "arn:aws:s3:::terraform-boostrap-nashtech-devops"
    ]
  }
}
