resource "random_id" "module_id" {
  byte_length = 6
}

locals {
  azs       = data.aws_availability_zones.azs.names
  az_count  = (length(data.aws_availability_zones.azs) >= 3) ? 3 : 2
  module_id = random_id.module_id.hex

  private_cidr = cidrsubnet(var.vpc_cidr, 1, 0)
  public_cidr  = cidrsubnet(var.vpc_cidr, 1, 1)

  tags = merge(tomap({ "module_id" : local.module_id }), var.tags)
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(tomap({ Name : "vpc-${local.module_id}" }), local.tags)
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(tomap({ Name : "igw-${local.module_id}" }), local.tags)
}

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id            = aws_vpc.vpc.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(local.public_cidr, 2, count.index)

  tags = merge(tomap({ "Name" : "public-${count.index + 1}", "type" : "public" }), local.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = merge(tomap({ "Name" : "public-${local.module_id}" }), local.tags)
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.vpc.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(local.private_cidr, 2, count.index)

  tags = merge(tomap({ "Name" : "private-${count.index + 1}", "type" : "private" }), local.tags)
}

resource "aws_route_table" "private" {
  count = local.az_count

  vpc_id = aws_vpc.vpc.id
  tags   = merge(tomap({ "Name" : "private-${count.index + 1}" }), local.tags)
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
