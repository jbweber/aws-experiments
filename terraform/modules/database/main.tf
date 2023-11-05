resource "random_id" "module_id" {
  byte_length = 6
}

locals {
  module_id = random_id.module_id.hex

  internal_db_subnet_group_name = "${coalesce(var.db_subnet_group_name, var.name)}-${local.module_id}"
  port                          = coalesce(var.port, 5432)

  backtrack_window = var.backtrack_window
  //(var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0


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
  allocated_storage                   = var.allocated_storage
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  apply_immediately                   = var.apply_immediately
  availability_zones                  = var.availability_zones
  backtrack_window                    = local.backtrack_window
  backup_retention_period             = var.backup_retention_period
  cluster_identifier                  = "${var.name}-${local.module_id}"
  cluster_members                     = var.cluster_members
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  database_name                       = var.database_name
  db_cluster_instance_class           = var.db_cluster_instance_class
  db_cluster_parameter_group_name     = var.db_cluster_db_instance_parameter_group_name
  deletion_protection                 = var.deletion_protection
  enable_global_write_forwarding      = var.enable_global_write_forwarding
  enable_http_endpoint                = var.enable_http_endpoint
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
  final_snapshot_identifier           = var.final_snapshot_identifier
  global_cluster_identifier           = var.global_cluster_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iops                                = var.iops
  kms_key_id                          = var.kms_key_id
  manage_master_user_password         = var.manage_master_user_password
  master_user_secret_kms_key_id       = var.master_user_secret_kms_key_id
  master_password                     = var.master_password
  master_username                     = var.master_username
  network_type                        = var.network_type
  port                                = local.port
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  replication_source_identifier       = var.replication_source_identifier

  dynamic "restore_to_point_in_time" {
    for_each = (length(var.restore_to_point_in_time) >0) ? [var.restore_to_point_in_time] : []

    content {
      restore_to_time            = try(restore_to_point_in_time.value.restore_to_time, null)
      restore_type               = try(restore_to_point_in_time.value.restore_type, null)
      source_cluster_identifier  = restore_to_point_in_time.source_cluster_identifier
      use_latest_restorable_time = try(restore_to_point_in_time.value.use_latest_restorable_time, null)
    }
  }

  skip_final_snapshot = var.skip_final_snapshot
  snapshot_identifier = var.snapshot_identifier
  source_region       = var.source_region
  storage_encrypted   = var.storage_encrypted
  storage_type        = var.storage_type

  vpc_security_group_ids = var.vpc_security_group_ids

  timeouts {
    create = try(var.cluster_timeouts.create, null)
    delete = try(var.cluster_timeouts.delete, null)
    update = try(var.cluster_timeouts.update, null)
  }

  tags = local.tags

  lifecycle {
    ignore_changes = []
  }
}
