# resource "aws_kms_key" "eks_dev" {
#   description             = "KMS key for DEV EKS"
#   deletion_window_in_days = 14

#   policy = data.aws_iam_policy_document.kms_use.json

#   tags = module.labels.tags
# }

# resource "aws_kms_alias" "eks_dev" {
#   name          = "alias/eks"
#   target_key_id = aws_kms_key.eks_dev.key_id
#   depends_on    = [aws_kms_key.eks_dev]
# }

# data "aws_iam_policy_document" "eks_dev_kms_use" {

#   statement {
#     sid       = "Enable Permissions for DevOps"
#     effect    = "Allow"
#     resources = ["*"]

#     actions = ["kms:*"]

#     principals {
#       type = "AWS"
#       identifiers = [
#         aws_iam_role.devops.arn,
#         "arn:aws:iam::768931539419:user/victor"
#       ]
#     }
#   }
# }