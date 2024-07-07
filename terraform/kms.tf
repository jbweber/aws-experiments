# data "aws_iam_policy_document" "kms_iam_policy_admin" {
#   version = "2012-10-17"

#   statement {
#     sid     = "1"
#     effect  = "Allow"
#     actions = [
#       "kms:Create*",
#       "kms:Describe*",
#       "kms:Enable*",
#       "kms:List*",
#       "kms:Put*",
#       "kms:Update*",
#       "kms:Revoke*",
#       "kms:Disable*",
#       "kms:Get*",
#       "kms:Delete*",
#       "kms:TagResource",
#       "kms:UntagResource",
#       "kms:Schedule*"
#     ]
#     resources = [
#       "arn:aws:kms:*:${data.aws_caller_identity.this.account_id}:alias/*",
#       "arn:aws:kms:*:${data.aws_caller_identity.this.account_id}:key/*",
#     ]
#   }

#   statement {
#     sid     = "2"
#     effect  = "Allow"
#     actions = [
#       "kms:CreateKey",
#       "kms:CreateAlias",
#     ]
#     resources = ["*"]
#   }
# }

# data "aws_iam_policy_document" "kms_resource_policy_default" {
#   policy_id = "kms-resource-policy-default"
#   version   = "2012-10-17"

#   statement {
#     sid       = "enable-management-via-iam"
#     effect    = "Allow"
#     actions   = ["kms:*"]
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
#     }
#   }
# }

# data "aws_iam_policy_document" "kms_resource_policy_test" {
#   version = "2012-10-17"

#   statement {
#     sid       = "enable-management-via-iam"
#     effect    = "Allow"
#     actions   = ["kms:*"]
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
#     }
#   }

#   statement {
#     sid     = "enable-test"
#     effect  = "Allow"
#     actions = [
#       "kms:DescribeKey",
#       "kms:ListKeys",
#     ]
#     resources = ["*"]
#     principals {
#       identifiers = ["arn:aws:iam::600613776922:role/jumphost-f1fef0fe7320"]
#       type        = "AWS"
#     }
#   }
# }


# data "aws_iam_policy_document" "rds" {

# }

# data "aws_iam_policy_document" "kms_resource_policy_secretsmanager" {
#   policy_id = "kms-resource-policy-secretsmanager"
#   version   = "2012-10-17"

#   dynamic "statement" {
#     for_each = (length(var.kms_administrators) > 0) ? toset(["admin"]) : toset([])

#     content {
#       sid     = "Allow Administrators of the key"
#       effect  = "Allow"
#       actions = [
#         "kms:Create*",
#         "kms:Describe*",
#         "kms:Enable*",
#         "kms:List*",
#         "kms:Put*",
#         "kms:Update*",
#         "kms:Revoke*",
#         "kms:Disable*",
#         "kms:Get*",
#         "kms:Delete*",
#         "kms:ScheduleKeyDeletion",
#         "kms:CancelKeyDeletion",
#       ]
#       resources = ["*"]
#       principals {
#         type        = "AWS"
#         identifiers = var.kms_administrators
#       }
#     }
#   }

#   # README: we really do NOT want to allow our account admin to create an IAM policy which
#   # can assign permission to delete keys with the restrictions we have here. Our issue is
#   # that if the role for our administrators is deleted we will lose the ability to manage
#   # this key so an outlet is required to avoid contacting AWS support always.
#   statement {
#     sid     = "Describe,Delete Key Only"
#     effect  = "Allow"
#     actions = [
#       "kms:Delete*",
#       "kms:DescribeKey"
#     ]
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
#     }
#   }

#   statement {
#     sid     = "Get Key Policy"
#     effect  = "Allow"
#     actions = [
#       "kms:GetKeyPolicy"
#     ]
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
#     }
#   }

#   statement {
#     sid     = "Allow KMS 1"
#     effect  = "Allow"
#     actions = [
#       "kms:CreateGrant",
#       "kms:Decrypt",
#       "kms:DescribeKey",
#       "kms:Encrypt",
#       "kms:ReEncrypt"
#     ]
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "kms:CallerAccount"
#       values   = [data.aws_caller_identity.this.account_id]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "kms:ViaService"
#       values   = ["secretsmanager.${var.aws_region}.amazonaws.com"]
#     }
#   }

#   statement {
#     sid     = "Allow KMS 2"
#     effect  = "Allow"
#     actions = [
#       "kms:GenerateDataKey"
#     ]
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "kms:CallerAccount"
#       values   = [data.aws_caller_identity.this.account_id]
#     }
#     condition {
#       test     = "StringLike"
#       variable = "kms:ViaService"
#       values   = ["secretsmanager.*.amazonaws.com"]
#     }
#   }

# }
