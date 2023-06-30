locals {
  ssh_public_key_filename = format("%s/%s", var.ssh_public_key_path, var.ssh_public_key_file)
}

resource "aws_key_pair" "imported" {
  key_name   = "key-${random_id.id.hex}"
  public_key = file(local.ssh_public_key_filename)

  tags = local.tags
}

data "aws_ssm_parameter" "amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "development-vm" {
  name   = "development-vm-${random_id.id.hex}"
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "development-vm-egress" {
  security_group_id = aws_security_group.development-vm.id
  description       = "Reason: allow access to the world."
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "development-vm-ingress-ssh" {
  description       = "Reason: allow access to the machine."
  security_group_id = aws_security_group.development-vm.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_ingress_cidr]
}

resource "aws_iam_role" "development-vm" {
  name = "development-vm-${random_id.id.hex}"

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

resource "aws_iam_instance_profile" "development-vm" {
  name = "development-vm-${random_id.id.hex}"
  role = aws_iam_role.development-vm.name
}

resource "aws_instance" "development-vm" {
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.development-vm.id]
  key_name               = aws_key_pair.imported.key_name
  iam_instance_profile   = aws_iam_instance_profile.development-vm.name

  tags = merge(tomap({ "Name" : "development-vm-${random_id.id.hex}" }), local.tags)
}

resource "aws_eip" "development-vm" {
  vpc = true

  tags = merge(tomap({ "Name" : "development-vm-eip-${random_id.id.hex}" }), local.tags)
}

resource "aws_eip_association" "development-vm" {
  instance_id   = aws_instance.development-vm.id
  allocation_id = aws_eip.development-vm.id
}
