variable "name" {
  type = string

  validation {
    condition     = can(regex("^[a-zA-Z][0-9a-zA-Z]+$", var.name))
    error_message = "name must start with a letter and contain only alpha numeric characters"
  }
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

variable "use_unique_id_suffix" {
  type    = bool
  default = false
}

# db subnet group

variable "db_subnet_group_name" {
  type    = string
  default = ""
}

variable db_subnet_group_subnets {
  type    = list(string)
  default = []
}

# cluster

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `2`"
  type        = number
  default     = 2
  validation {
    condition     = var.backup_retention_period >= 2 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 2 and 35"
  }
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  validation {
    condition     = lower(var.database_name) != "postgres"
    error_message = "database_name cannot be 'postgres'"
  }
  validation {
    condition     = can(regex("^[a-zA-Z][0-9a-zA-Z]+$", var.database_name))
    error_message = "database_name must start with a letter and contain only alpha numeric characters"
  }
}

variable "db_cluster_db_instance_parameter_group_name" {
  description = "Instance parameter group to associate with all instances of the DB cluster. The `db_cluster_db_instance_parameter_group_name` is only valid in combination with `allow_major_version_upgrade`"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
  default     = "14.9"
  validation {
    condition     = (tonumber(split(".", var.engine_version)[0]) >= 14 && tonumber(split(".", var.engine_version)[1]) >= 9) || tonumber(var.engine_version) >= 15
    error_message = "engine_version must be equal or greater than version 14.9"
  }
  validation {
    condition     = can(regex("\\.", var.engine_version))
    error_message = "engine_version must be fully specified"
  }
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made"
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  type        = string
  default     = null
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if `master_password` is provided"
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "The Amazon Web Services KMS key identifier is the key ARN, key ID, alias ARN, or alias name for the KMS key"
  type        = string
  default     = null
}

variable "master_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Required unless `manage_master_user_password` is set to `true` or unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user. Required unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database"
  type        = string
  default     = null
}

variable "network_type" {
  description = "The type of network stack to use (IPV4 or DUAL)"
  type        = string
  default     = null
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "21:00-22:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:22:00-sun:23:00"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = false
}



variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. The default is `true`"
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "Determines the storage type for the DB cluster. Optional for Single-AZ, required for Multi-AZ DB clusters. Valid values for Single-AZ: `aurora`, `\"\"` (default, both refer to Aurora Standard), `aurora-iopt1` (Aurora I/O Optimized). Valid values for Multi-AZ: `io1` (default)."
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the security group created"
  type        = list(string)
  default     = []
}
