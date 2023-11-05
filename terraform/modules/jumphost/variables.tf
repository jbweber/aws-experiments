variable "vpc_id" {
  type = string
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "ssh_ingress_cidrs" {
  type    = list(string)
  default = []
}

variable "ssh_public_key" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "unique_id" {
  type    = string
  default = ""
}
