variable "attach_external_ip" {
  type    = bool
  default = false
}

variable "hostname" {
  type = string
}

variable "hostname_use_unique_id_suffix" {
  type    = bool
  default = false
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
  type        = string
  description = "A user defined unique identifier which can be used to make resources unique. If none is passed the module_id will be used."
  default     = ""
}
