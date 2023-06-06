

# output "kms_eks_id" {
#   value = aws_kms_key.eks_dev.key_id
# }

# output "kms_eks_alias_arn" {
#   value = aws_kms_alias.eks_dev.arn
# }

########### WORKSPACE KMS ###########

output "kms_bootstrap_id" {
  value = aws_kms_key.terraform-bootstrap.key_id
}

output "kms_bootstrap_alias_arn" {
  value = aws_kms_alias.terraform-bootstrap.arn
}

########### GROUP / ROLE / USER ARN and NAME ###########

output "devops_group_arn" {
  value = aws_iam_group.devops.arn
}

output "devops_role_arn" {
  value = aws_iam_role.devops.arn
}

output "devops_user_arn" {
  value = { for user in local.devops : user.name => user.arn }
}

output "bastion_role_arn" {
  value = aws_iam_role.bastion.arn
}

output "bastion_role_name" {
  value = aws_iam_role.bastion.name
}

