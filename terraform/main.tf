resource "random_id" "id" {
  byte_length = 8
}

# data "aws_availability_zones" "azs" {
#   state = "available"
# }

data "aws_caller_identity" "this" {}


locals {
  tags = {
    "developer_initials" : var.developer_initals
  }

  ssh_public_key = file(format("%s/%s", var.ssh_public_key_path, var.ssh_public_key_file))
}
#   az_count = (length(data.aws_availability_zones.azs) >= 3) ? 3 : 2

#   vpc_cidr = "${var.vpc_network_address}/${var.vpc_network_bits}"

#   s1 = cidrsubnet(local.vpc_cidr, 1, 0)
#   s2 = cidrsubnet(local.vpc_cidr, 1, 1)

#   s3 = cidrsubnet(local.s2, 2, 0)
#   s4 = cidrsubnet(local.s2, 2, 1)

# }

#module "network" {
#  source = "./modules/network"
#
#  vpc_cidr = var.vpc_cidr
#  tags     = local.tags
#}
#
#module "jumphost" {
#  source = "./modules/jumphost"
#
#  ssh_ingress_cidrs = var.ssh_ingress_cidrs
#  ssh_public_key    = local.ssh_public_key
#  vpc_id            = module.network.vpc_id
#}

#module "database" {
#  source = "./modules/database"
#
#  name                    = "jwdb"
#  db_subnet_group_subnets = module.network.private_subnet_ids
#
#  tags = local.tags
#}

#module "my_key" {
#  source = "./modules/kms"
#
#  alias               = "bob"
#  enable_key_rotation = true
#  policy = data.aws_iam_policy_document.kms_resource_policy_default.json
#}
