variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "enable_ipv4" {
  type    = bool
  default = true
}

variable "enable_ipv4_nat" {
  type = bool
  default = false
}

variable "enable_ipv6" {
  type    = bool
  default = false
}

variable "enable_ipv6_private_egress" {
  type    = bool
  default = false
}

variable "unique_id" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
