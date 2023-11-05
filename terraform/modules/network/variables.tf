variable "vpc_cidr" {
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
