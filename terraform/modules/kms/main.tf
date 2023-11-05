resource "random_id" "this" {
  byte_length = 6
}

locals {
  module_id = random_id.this.hex

  tags = merge({ "module_id" : local.module_id }, var.tags)
}

data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "this" {
  statement {

  }
}

resource aws_kms_key "this" {
  bypass_policy_lockout_safety_check = false
  customer_master_key_spec           = var.customer_master_key_spec
  custom_key_store_id                = null
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enable_key_rotation                = var.enable_key_rotation
  is_enabled                         = true
  key_usage                          = var.key_usage
  multi_region                       = false # TODO enable feature
  policy                             = var.policy

  tags = local.tags
}

resource "aws_kms_alias" "this" {
  count         = (var.alias == "") ? 0 : 1
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.id
}
