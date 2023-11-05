resource "random_id" "module_id" {
  byte_length = 6
}

locals {
  module_id = random_id.module_id.hex
  unique_id = (var.unique_id == "") ? local.module_id : var.unique_id
}

locals {
  # db subnet group

  # cluster
  cluster_identifier = var.use_unique_id_suffix ? "cluster-${var.name}-${local.unique_id}" : "cluster-${var.name}"

  engine      = "aurora-postgresql"
  engine_mode = "provisioned"


  internal_db_subnet_group_name = "${coalesce(var.db_subnet_group_name, var.name)}-${local.module_id}"


  tags = merge(tomap({ "module_id" : local.module_id }), var.tags)
}

# db subnet group
resource "aws_db_subnet_group" "this" {
  name        = local.internal_db_subnet_group_name
  description = "subnet group for aurora cluster ${var.name}"
  subnet_ids  = var.db_subnet_group_subnets

  tags = local.tags
}

# db cluster
resource "aws_rds_cluster" "this" {
  allocated_storage                   = null
  allow_major_version_upgrade         = false
  apply_immediately                   = false
  availability_zones                  = null
  backtrack_window                    = 0
  backup_retention_period             = var.backup_retention_period
  cluster_identifier                  = local.cluster_identifier
  copy_tags_to_snapshot               = false
  database_name                       = var.database_name
  db_cluster_parameter_group_name     = var.db_cluster_db_instance_parameter_group_name # TODO
  db_instance_parameter_group_name    = var.db_cluster_db_instance_parameter_group_name # TODO
  deletion_protection                 = var.deletion_protection
  enable_http_endpoint                = null
  engine                              = local.engine
  engine_mode                         = local.engine_mode
  engine_version                      = var.engine_version
  final_snapshot_identifier           = var.final_snapshot_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  kms_key_id                          = var.kms_key_id
  manage_master_user_password         = var.manage_master_user_password
  master_user_secret_kms_key_id       = var.master_user_secret_kms_key_id
  master_password                     = var.master_password
  master_username                     = var.master_username
  network_type                        = var.network_type
  port                                = 5432
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  replication_source_identifier       = null
  skip_final_snapshot                 = var.skip_final_snapshot
  storage_encrypted                   = var.storage_encrypted
  storage_type                        = var.storage_type
  vpc_security_group_ids              = var.vpc_security_group_ids

  tags = local.tags

  lifecycle {
    ignore_changes = []
  }
}
