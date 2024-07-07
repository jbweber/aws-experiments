data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  azs      = data.aws_availability_zones.azs.names
  az_count = (length(data.aws_availability_zones.azs) >= 3) ? 3 : 2
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  instance_tenancy = "default"

  assign_generated_ipv6_cidr_block = true

  tags = merge(tomap({ Name : "vpc-${local.unique_id}" }), local.tags)
}

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id                          = aws_vpc.this.id
  assign_ipv6_address_on_creation = true
  availability_zone               = local.azs[count.index]

  ipv6_native                                    = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index)
  enable_dns64                                   = true
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = true

  tags = merge(tomap({ "Name" : "public-${local.unique_id}-${count.index}" }), local.tags)
}

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id                          = aws_vpc.this.id
  assign_ipv6_address_on_creation = true
  availability_zone               = local.azs[count.index]

  ipv6_native                                    = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, (count.index + local.az_count))
  enable_dns64                                   = true
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = true

  tags = merge(tomap({ "Name" : "private-${local.unique_id}-${count.index}" }), local.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(tomap({ Name : "igw-${local.unique_id}" }), local.tags)
}

resource "aws_route" "public2igw" {
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}

resource "aws_route" "public-ipv6" {
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
  route_table_id              = aws_route_table.public.id
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
