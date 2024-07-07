# core
variable "developer_initals" {
  type        = string
  description = "initial of the developer using this code, to provide ownership tag"
}

# network
variable "vpc_cidr" {
  type    = string
  default = "10.64.64.0/18"
}

# ssh
variable "ssh_public_key_file" {
  type    = string
  default = "id_rsa.pub"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh"
}

variable "ssh_ipv4_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ssh_ipv6_ingress_cidrs" {
  type    = list(string)
  default = ["::/0"]
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

#
# variable "kms_administrators" {
#   type    = list(string)
#   default = []
# }
