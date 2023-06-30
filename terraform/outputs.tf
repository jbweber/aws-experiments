output "development-vm-eip" {
  value = aws_eip.development-vm.public_ip
}
