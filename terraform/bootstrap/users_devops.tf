locals {
  devops = [
    {
      "arn" : aws_iam_user.devops_member_1.arn
      "name" : aws_iam_user.devops_member_1.name
    },
    {
      "arn" : aws_iam_user.devops_member_2.arn
      "name" : aws_iam_user.devops_member_2.name
    },
  ]
}

############# DEVOPS MEMBERS ##############

resource "aws_iam_user" "devops_member_1" {
  name          = "testing-user-1-${var.project}"
  force_destroy = true

  tags = {
    GitHub = "testing1"
    Office = "Saigon"
    Team   = "DevOps"
  }
}

resource "aws_iam_user" "devops_member_2" { # another user example
  name          = "testing-user-2-${var.project}"
  force_destroy = true

  tags = {
    GitHub = "testing2"
    Office = "Saigon"
    Team   = "DevOps"
  }
}

resource "aws_iam_group_membership" "devops_group_membership" {
  group = aws_iam_group.devops.id
  name  = aws_iam_group.devops.name
  users = [for user in local.devops : user.name]
}

