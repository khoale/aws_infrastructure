resource "aws_iam_role" "bastion" {
  name               = "bastion-${var.project}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.trust-policies-bastion-assume-role.json
}

resource "aws_iam_role_policy" "bastion" {
  name   = "bastion-role-${var.project}-policy"
  role   = aws_iam_role.bastion.id
  policy = data.aws_iam_policy_document.bastion-role-policy.json
}

# data "aws_iam_policy_document" "bastion-assume-role-policy" {
#   statement {
#     actions = [
#       "sts:AssumeRole",
#     ]

#     resources = [
#       aws_iam_role.bastion.arn
#     ]
#   }
# }

# Define what user/service have permission to execute the AssumeRole action is needed
# We have a Role and we should define what user/service can assume that role
# Note: "group" is not a valid principals https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_principal.html
data "aws_iam_policy_document" "trust-policies-bastion-assume-role" {
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

# We define what bastion role can do here Identity-base policies

data "aws_iam_policy_document" "bastion-role-policy" {
  statement {
    actions = [
      "*"
    ]

    resources = [
      "arn:aws:s3:::terraform-boostrap-nashtech-devops"
    ]
  }
}
