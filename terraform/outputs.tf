output "jumphost_external_ip" {
  value = module.jumphost.external_ip
}

output "jumphost_public_dns" {
  value = module.jumphost.public_dns
}

output "jumphost_public_ip" {
  value = module.jumphost.public_ip
}

output "jumphost_private_ip" {
  value = module.jumphost.private_ip
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
