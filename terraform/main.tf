resource "random_id" "this" {
  byte_length = 6
}

locals {
  ssh_public_key = file(format("%s/%s", var.ssh_public_key_path, var.ssh_public_key_file))

  unique_id = random_id.this.hex

  tags = {
    "created-by" : "aws-experiments",
    "developer_initials" : var.developer_initals,
  }
}

# module "ipv4-only" {
#   source = "./modules/network"

#   vpc_cidr    = "10.0.0.0/16"
#   unique_id   = "ipv4-only"
#   enable_ipv4 = true
#   enable_ipv6 = false

#   tags = local.tags
# }

# module "ipv6-only" {
#   source = "./modules/network"

#   vpc_cidr    = "10.0.0.0/16"
#   unique_id   = "ipv6-only"
#   enable_ipv4 = false
#   enable_ipv6 = true

#   tags = local.tags
# }

module "dual-stack" {
  source = "./modules/network"

  vpc_cidr                   = "10.0.0.0/16"
  unique_id                  = "dual-stack"
  enable_ipv4                = true
  enable_ipv4_nat            = true
  enable_ipv6                = true
  enable_ipv6_private_egress = true

  tags = local.tags
}

module "jumphost" {
  source = "./modules/instance"

  attach_external_ip            = false
  hostname                      = "jumphost"
  hostname_use_unique_id_suffix = true
  ssh_ipv4_ingress_cidrs        = var.ssh_ipv4_ingress_cidrs
  ssh_ipv6_ingress_cidrs        = var.ssh_ipv6_ingress_cidrs
  ssh_public_key                = local.ssh_public_key
  subnet_id                     = module.dual-stack.public_subnet_ids[0]
  unique_id                     = local.unique_id
}

# module "kms_secretsmanager" {
#   source = "./modules/kms"

#   alias               = "secretsmanager"
#   enable_key_rotation = true
#   policy              = data.aws_iam_policy_document.kms_resource_policy_secretsmanager.json
# }

# module "database" {
#   source = "./modules/database"

#   database_name                 = "jwdb"
#   master_username               = "root"
#   master_user_secret_kms_key_id = module.kms_secretsmanager.kms_key_arn
#   manage_master_user_password   = true
#   name                          = "jwdb"
#   db_subnet_group_subnets       = module.network.private_subnet_ids


#   tags = local.tags
# }

#module "my_key" {
#  source = "./modules/kms"
#
#  alias               = "bob"
#  enable_key_rotation = true
#  policy = data.aws_iam_policy_document.kms_resource_policy_default.json
#}
