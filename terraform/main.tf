resource "random_id" "id" {
  byte_length = 8
}

locals {
  tags = {
    "developer_initials" : var.developer_initals
  }
}
