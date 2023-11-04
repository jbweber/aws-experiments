
resource "random_id" "module_id" {
  byte_length = 6
}

locals {
  module_id = random_id.module_id.hex

  tags = merge(tomap({ "module_id" : local.module_id }), var.tags)
}

data "aws_ssm_parameter" "amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:type"
    values = ["public"]
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "key-${local.module_id}"
  public_key = var.ssh_public_key

  tags = local.tags
}

resource "aws_security_group" "security_group" {
  name   = "jumphost-${local.module_id}"
  vpc_id = var.vpc_id

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress_anywhere" {
  security_group_id = aws_security_group.security_group.id
  description       = "Reason: allow access to the world"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_ssh" {
  for_each = (length(var.ssh_ingress_cidrs) > 0) ? { "do" : "" } : {}

  description       = "Reason: allow access to the jumphost"
  security_group_id = aws_security_group.security_group.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_ingress_cidrs
}

resource "aws_iam_role" "jumphost" {
  name = "jumphost-${local.module_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jumphost" {
  name = "jumphost-${local.module_id}"
  role = aws_iam_role.jumphost.name
}

resource "aws_instance" "jumphost" {
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.subnets.ids[0]
  vpc_security_group_ids = [aws_security_group.security_group.id]
  key_name               = aws_key_pair.key_pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.jumphost.name

  tags = merge(tomap({ "Name" : "jumphost-${local.module_id}" }), local.tags)
}

resource "aws_eip" "jumphost" {
  vpc = true

  tags = merge(tomap({ "Name" : "jumphost-eip-${local.module_id}" }), local.tags)
}

resource "aws_eip_association" "jumphost" {
  instance_id   = aws_instance.jumphost.id
  allocation_id = aws_eip.jumphost.id
}

