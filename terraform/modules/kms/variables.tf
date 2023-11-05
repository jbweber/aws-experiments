variable "alias" {
  type    = string
  default = ""
}

variable "customer_master_key_spec" {
  type        = string
  description = "specifies whether the key contains a symmetric or asymmetric key and the algorithms the key supports"
  default     = "SYMMETRIC_DEFAULT"

  validation {
    condition = contains([
      "SYMMETRIC_DEFAULT",
      "RSA_2048",
      "RSA_3072",
      "RSA_4096",
      "HMAC_256",
      "ECC_NIST_P256",
      "ECC_NIST_P384",
      "ECC_NIST_P521",
      "ECC_SECG_P256K1"
    ], var.customer_master_key_spec)
    error_message = "invalid value passed for customer_master_key_spec"
  }
}

variable "deletion_window_in_days" {
  type        = number
  description = "waiting period specified in days before a key is permanently deleted"
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30 inclusive"
  }
}

variable "description" {
  type    = string
  default = ""
}

variable "enable_key_rotation" {
  type    = bool
  default = null
}

variable "key_usage" {
  type        = string
  description = "specifies intended usage of they key"
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition = contains([
      "ENCRYPT_DECRYPT",
      "SIGN_VERIFY",
      "GENERATE_VERIFY_MAC"
    ], var.key_usage)
    error_message = "invalid value passed for key_usage, must be one of [\"ENCRYPT_DECRYPT\", \"SIGN_VERIFY\", \"GENERATE_VERIFY_MAC\"]"
  }
}

variable "policy" {
  type        = string
  description = "kms key resource policy"
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
