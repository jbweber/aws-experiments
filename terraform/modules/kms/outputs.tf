output "kms_alias_arn" {
  value = aws_kms_alias.this.arn
}

output "kms_alias_name" {
  value = aws_kms_alias.this.name
}

output "kms_key_arn" {
  value = aws_kms_key.this.arn
}
