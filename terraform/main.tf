resource "random_id" "id" {
  byte_length = 8
}

# data "aws_availability_zones" "azs" {
#   state = "available"
# }

locals {
  tags = {
    "developer_initials" : var.developer_initals
  }
}
#   az_count = (length(data.aws_availability_zones.azs) >= 3) ? 3 : 2

#   vpc_cidr = "${var.vpc_network_address}/${var.vpc_network_bits}"

#   s1 = cidrsubnet(local.vpc_cidr, 1, 0)
#   s2 = cidrsubnet(local.vpc_cidr, 1, 1)

#   s3 = cidrsubnet(local.s2, 2, 0)
#   s4 = cidrsubnet(local.s2, 2, 1)

# }

module "network" {
  source = "./modules/network"

  vpc_cidr = var.vpc_cidr
  tags     = local.tags
}
