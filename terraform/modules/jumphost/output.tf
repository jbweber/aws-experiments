output "jumphost_ip" {
  value = aws_eip.jumphost.public_ip
}
