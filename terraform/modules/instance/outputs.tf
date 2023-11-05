output "external_ip" {
  value = var.attach_external_ip ? aws_eip.this[0].public_ip : ""
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "public_dns" {
  value = aws_instance.this.public_dns
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
