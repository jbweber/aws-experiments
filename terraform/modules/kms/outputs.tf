output "kms_alias_arn" {
  value = aws_kms_alias.this[0].arn
}

output "kms_alias_name" {
  value = aws_kms_alias.this[0].name
}

output "kms_key_arn" {
  value = aws_kms_key.this.arn
}
