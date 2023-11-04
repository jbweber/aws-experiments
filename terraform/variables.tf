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

variable "vpc_network_address" {
  type    = string
  default = "10.64.64.0"
}

variable "vpc_network_bits" {
  type    = number
  default = 18
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.64.64.0/20"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.64.96.0/20"
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

variable "ssh_ingress_cidr" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}
