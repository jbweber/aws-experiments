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

variable "ssh_ingress_cidrs" {
  type = list(string)
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}
