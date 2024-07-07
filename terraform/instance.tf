data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "key-${local.unique_id}"
  public_key = local.ssh_public_key

  tags = local.tags
}


resource "aws_security_group" "test_sg" {
  name                   = "Test-SG"
  description            = "Security Group for the Test EC2 instance"
  revoke_rules_on_delete = true
  tags = {
    "Name" = "Test-SG"
  }
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.test_sg.id
  protocol = "tcp"
  from_port = 22
  to_port = 22
  ipv6_cidr_blocks = ["::0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.test_sg.id
  protocol = -1
  from_port = -1
  to_port = -1
  ipv6_cidr_blocks = ["::0/0"]
  type = "egress"
}

resource "aws_instance" "test" {
  key_name               = aws_key_pair.this.key_name
  ami                     = data.aws_ami.amazon_linux_2.id # Dynamically chosen Amazon Linux AMI
  ebs_optimized           = true                           # EBS Optimised instance
  instance_type           = "t4g.nano"                     # Using a Graviton based instance here
  disable_api_termination = true                           # Always good practice to stop pet instances being terminated

  # Networking settings, setting the private IP to the 10th IP in the subnet, and attaching to the right SG and Subnets
  source_dest_check      = false
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.test_sg.id]

  # This requires that the metadata endpoint on the instance uses the new IMDSv2 secure endpoint
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Sets the size of the EBS root volume attached to the instance
  root_block_device {
    volume_size           = "8"   # In GB
    volume_type           = "gp3" # Volume Type
    encrypted             = true  # Always best practice to encrypt
    delete_on_termination = true  # Make sure that the volume is deleted on termination
  }

  # Name of the instance, for the console
  tags = {
    "Name" = "Sample-EC2-Instance"
  }
}
