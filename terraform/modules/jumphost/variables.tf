variable "vpc_id" {
  type = string
}

variable "ssh_ingress_cidrs" {
  type    = list(string)
  default = []
}

variable "ssh_public_key" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
