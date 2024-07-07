resource "random_id" "this" {
  byte_length = 6
}

locals {
  azs                = data.aws_availability_zones.this.names
  az_count           = (length(data.aws_availability_zones.this) >= 3) ? 3 : 2
  module_instance_id = random_id.this.hex
  unique_id          = (var.unique_id != "") ? var.unique_id : local.module_instance_id

  private_cidr = cidrsubnet(var.vpc_cidr, 1, 0)
  public_cidr  = cidrsubnet(var.vpc_cidr, 1, 1)

  tags = merge(tomap({ "module_instance_id" : local.module_instance_id, "unique_id" : local.unique_id }), var.tags)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(tomap({ Name : "${local.unique_id}-vpc" }), local.tags)
}

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = var.enable_ipv4 ? cidrsubnet(local.public_cidr, 2, count.index) : null

  assign_ipv6_address_on_creation                = var.enable_ipv6
  enable_dns64                                   = false # RESEARCH ME
  ipv6_native                                    = var.enable_ipv4 ? false : true
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_ipv6
  ipv6_cidr_block                                = var.enable_ipv6 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index) : null

  tags = merge(tomap({ "Name" : "${local.unique_id}-public-${local.azs[count.index]}", "type" : "public" }), local.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(tomap({ "Name" : "${local.unique_id}-rtb-public" }), local.tags)
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(tomap({ Name : "${local.unique_id}-igw" }), local.tags)
}

resource "aws_route" "ipv4gateway" {
  count = var.enable_ipv4 ? 1 : 0

  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "ipv6gateway" {
  count = var.enable_ipv6 ? 1 : 0

  route_table_id              = aws_route_table.public.id
  gateway_id                  = aws_internet_gateway.this.id
  destination_ipv6_cidr_block = "::/0"
}

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = var.enable_ipv4 ? cidrsubnet(local.private_cidr, 2, count.index) : null

  assign_ipv6_address_on_creation                = var.enable_ipv6
  enable_dns64                                   = false # RESEARCH ME
  ipv6_native                                    = var.enable_ipv4 ? false : true
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_ipv6
  ipv6_cidr_block                                = var.enable_ipv6 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, (count.index + local.az_count)) : null

  tags = merge(tomap({ "Name" : "${local.unique_id}-private-${local.azs[count.index]}", "type" : "private" }), local.tags)
}

resource "aws_route_table" "private" {
  count = local.az_count

  vpc_id = aws_vpc.this.id
  tags   = merge(tomap({ "Name" : "${local.unique_id}-rtb-private-${local.azs[count.index]}" }), local.tags)
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_egress_only_internet_gateway" "ipv6_private_egress" {
  count = var.enable_ipv6 && var.enable_ipv6_private_egress ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(tomap({ Name : "${local.unique_id}-eoigw" }), local.tags)
}

resource "aws_route" "ipv6_private_egress" {
  count = (var.enable_ipv6 && var.enable_ipv6_private_egress) ? local.az_count : 0

  route_table_id              = aws_route_table.private[count.index].id
  egress_only_gateway_id      = aws_egress_only_internet_gateway.ipv6_private_egress[0].id
  destination_ipv6_cidr_block = "::/0"
}

resource "aws_eip" "nat" {
  count = var.enable_ipv4 && var.enable_ipv4_nat ? local.az_count : 0

  domain = "vpc"

  tags = merge(tomap({ Name : "${local.unique_id}-nat-eip-${local.azs[count.index]}" }), local.tags)
}

resource "aws_nat_gateway" "this" {
  count = var.enable_ipv4 && var.enable_ipv4_nat ? local.az_count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(tomap({ Name : "${local.unique_id}-nat-${local.azs[count.index]}" }), local.tags)
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_ipv4 && var.enable_ipv4_nat ? local.az_count : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}
