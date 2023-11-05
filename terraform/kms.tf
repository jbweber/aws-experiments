data "aws_iam_policy_document" "kms_iam_admin" {
  version = "2012-10-17"

  statement {
    sid     = "1"
    effect  = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Schedule*"
    ]
    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.this.account_id}:alias/*",
      "arn:aws:kms:*:${data.aws_caller_identity.this.account_id}:key/*",
    ]
  }

  statement {
    sid     = "2"
    effect  = "Allow"
    actions = [
      "kms:CreateKey",
      "kms:CreateAlias",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "default" {

}

data "aws_iam_policy_document" "rds" {

}

data "aws_iam_policy_document" "kms_key_policy_secretsmanager" {
  version = "2012-10-17"

  dynamic "statement" {
    for_each = (length(var.kms_administrators) > 0) ? toset(["admin"]) : toset([])

    content {
      sid     = "Allow Administrators of the key"
      effect  = "Allow"
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = var.kms_administrators
      }
    }
  }

  # README: we really do NOT want to allow our account admin to create an IAM policy which
  # can assign permission to delete keys with the restrictions we have here. Our issue is
  # that if the role for our administrators is deleted we will lose the ability to manage
  # this key so an outlet is required to avoid contacting AWS support always.
  statement {
    sid     = "Describe,Delete Key Only"
    effect  = "Allow"
    actions = [
      "kms:Delete*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }

  statement {
    sid     = "Get Key Policy"
    effect  = "Allow"
    actions = [
      "kms:GetKeyPolicy"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }

  statement {
    sid     = "Allow KMS 1"
    effect  = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${var.aws_region}.amazonaws.com"]
    }
  }

  statement {

  }

}
