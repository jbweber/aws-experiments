resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = merge(tomap({ "Name" : "vpc-${random_id.id.hex}" }), local.tags)
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(tomap({ "Name" : "igw-${random_id.id.hex}" }), local.tags)
}

resource "aws_subnet" "public" {
  cidr_block = var.public_subnet_cidr
  vpc_id     = aws_vpc.vpc.id

  tags = merge(tomap({ "Name" : "public-${random_id.id.hex}" }), local.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = merge(tomap({ "Name" : "public-${random_id.id.hex}" }), local.tags)
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  cidr_block = var.private_subnet_cidr
  vpc_id     = aws_vpc.vpc.id

  tags = merge(tomap({ "Name" : "private-${random_id.id.hex}" }), local.tags)
}
