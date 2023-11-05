resource "random_id" "this" {
  byte_length = 6
}

locals {
  module_id = random_id.this.hex
  unique_id = (var.unique_id != "") ? var.unique_id : local.module_id

  tags = merge(tomap({ "module_id" : local.module_id, "unique_id" : local.unique_id }), var.tags)
}

resource "aws_key_pair" "this" {
  key_name   = "key-${local.unique_id}"
  public_key = var.ssh_public_key

  tags = local.tags
}

resource "aws_security_group" "this" {
  name   = "jumphost-${local.unique_id}"
  vpc_id = var.vpc_id

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress_anywhere" {
  security_group_id = aws_security_group.this.id
  description       = "Reason: allow access to the world"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_ssh" {
  for_each = (length(var.ssh_ingress_cidrs) > 0) ? toset(["do"]) : toset([])

  description       = "Reason: allow access to the jumphost"
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_ingress_cidrs
}

resource "aws_iam_role" "this" {
  name = "jumphost-${local.unique_id}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "jumphost-${local.unique_id}"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = concat([aws_security_group.this.id], var.security_groups)
  key_name               = aws_key_pair.this.key_name
  iam_instance_profile   = aws_iam_instance_profile.this.name

  tags = merge(tomap({ "Name" : "jumphost-${local.unique_id}" }), local.tags)

  lifecycle {
    ignore_changes = [subnet_id]
  }
}

resource "aws_eip" "this" {
  tags = merge(tomap({ "Name" : "jumphost-eip-${local.unique_id}" }), local.tags)
}

resource "aws_eip_association" "this" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this.id
}
